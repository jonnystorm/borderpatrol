defmodule Repo do
  use Ecto.Repo, otp_app: :borderpatrol

  import Ecto.Query

  def get_edge_interface(id) do
    query = from e in EdgeInterface,
      where: e.id == ^id,
      select: e,
      preload: [:edge_device, endpoints: :border_profiles]
    [edge_interface] = Repo.all(query)

    edge_interface
  end

  def find_edge_interfaces(params) do
    query = from e in EdgeInterface

    if name = params["name"] do
      query = from e in query, where: e.name == ^name
    end

    query = from e in query, select: e,
      preload: [:edge_device, endpoints: :border_profiles]

    Repo.all(query)
  end

  def get_endpoint(id) do
    query = from e in Endpoint,
      where: e.id == ^id,
      select: e,
      preload: :border_profiles
    [endpoint] = Repo.all(query)

    endpoint
  end

  def find_endpoints(params) do
    query = from e in Endpoint

    if name = params["name"] do
      query = from e in query, where: e.name == ^name
    end
    if ip = params["ip"] do
      query = from e in query, where: e.ip_addr == ^ip
    end
    if mac = params["mac"] do
      query = from e in query, where: e.mac_addr == ^mac
    end

    query = from e in query,
      select: e,
      preload: [:edge_interface, :border_profiles]

    Repo.all(query)
  end

  def get_border_profile(id) do
    query = from e in Endpoint,
      where: e.id == ^id,
      select: e
    [endpoint] = Repo.all(query)

    endpoint
  end

  def get_edge_device(id) do
    query = from e in EdgeDevice,
      where: e.id == ^id,
      select: e
    [edge_device] = Repo.all(query)

    edge_device
  end

  def find_edge_devices(params) do
    query = from e in EdgeDevice

    if name = params["name"] do
      query = from e in query, where: e.name == ^name
    end
    if ip = params["ip"] do
      query = from e in query, where: e.ip_addr == ^ip
    end

    query = from e in query, select: e

    Repo.all(query)
  end

  def find_border_profiles(params) do
    query = from p in BorderProfile

    if name = params["name"] do
      query = from p in query, where: p.name == ^name
    end
    
    query = from p in query, select: p

    Repo.all(query)
  end

  def get_endpoint_to_border_profile(id) do
    query = from e in EndpointToBorderProfile,
      where: e.id == ^id,
      select: e
    [e_to_bp] = Repo.all(query)

    e_to_bp
  end

  def find_endpoint_to_border_profiles(params) do
    query = from e in EndpointToBorderProfile

    if endpoint_id = params["endpoint_id"] do
      query = from e in query, where: e.endpoint_id == ^endpoint_id
    end
    if profile_id = params["border_profile_id"] do
      query = from e in query, where: e.border_profile_id == ^profile_id
    end

    query = from e in query, select: e

    Repo.all(query)
  end

  def add_endpoint(name, ip, mac) do
    Endpoint.create(%{name: name, ip_addr: ip, mac_addr: mac})
  end

  def update_endpoint(params, id) do
    Endpoint.update(id, params)
  end

  def unassign_profiles(endpoint, profiles) do
    profiles
      |> Enum.reduce(fn(p, acc) ->
        acc ++ find_endpoint_to_border_profiles(
          [endpoint_id: endpoint.id, border_profile_id: p.id]
        )
      end)
      |> Enum.map(&(EndpointToBorderProfile.drop &1))
  end

  def assign_profiles(endpoint, profiles) do
    profiles
      |> Enum.map(fn p ->
        EndpointToBorderProfile.create(
          %{endpoint_id: endpoint.id, border_profile_id: p.id}
        )
      end)
  end
end

defmodule EdgeDevice do
  use Ecto.Model

  schema "edge_devices" do
    field :hostname
    field :ip_addr
    has_many :edge_interface_to_edge_devices, EdgeInterfaceToEdgeDevice
    has_many :edge_interfaces,
      through: [:edge_interface_to_edge_devices, :edge_interface]
  end

  def changeset(edge_device, params \\ nil) do
    edge_device
      |> cast(params, ~w(hostname ip_addr))
      |> validate_format(:hostname, ~r/^[a-zA-Z0-9][a-zA-Z0-9\-\._]*$/)
      |> validate_format(:ip_addr, Util.ipv4_regex)
      |> validate_unique(:hostname, on: Repo)
      |> validate_unique(:ip_addr, on: Repo)
  end

  def create(_id, params) do
    changeset = changeset(%EdgeDevice{}, params)

    case changeset.valid? do
      true ->
        Repo.insert(changeset)
      false ->
        nil
    end
  end
end

defmodule EdgeInterface do
  use Ecto.Model

  schema "edge_interfaces" do
    field :name
    has_one :edge_interface_to_edge_device, EdgeInterfaceToEdgeDevice
    has_many :edge_interface_to_endpoints, EdgeInterfaceToEndpoint
    has_one :edge_device,
      through: [:edge_interface_to_edge_device, :edge_device]
    has_many :endpoints,
      through: [:edge_interface_to_endpoints, :endpoint]
    has_many :jobs, Job
  end

  def changeset(edge_interface, params \\ nil) do
    edge_interface
      |> cast(params, ~w(name))
      |> validate_format(:name, ~r/^[a-zA-Z][a-zA-Z0-9\-\._\/]*$/)
      |> validate_unique(:name, on: Repo)
  end

  def create(_id, params) do
    changeset = changeset(%EdgeInterface{}, params)

    case changeset.valid? do
      true ->
        Repo.insert(changeset)
      false ->
        nil
    end
  end
end

defmodule Endpoint do
  use Ecto.Model

  schema "endpoints" do
    field :name
    field :ip_addr
    field :mac_addr
    has_one :edge_interface_to_endpoint, EdgeInterfaceToEndpoint
    has_many :endpoint_to_border_profiles, EndpointToBorderProfile
    has_one :edge_interface,
      through: [:edge_interface_to_endpoint, :edge_interface]
    has_many :border_profiles,
      through: [:endpoint_to_border_profiles, :border_profile]
  end

  def changeset(endpoint, params \\ nil) do
    endpoint
      |> cast(params, ~w(name ip_addr mac_addr))
      |> validate_format(:name, ~r/^[a-zA-Z0-9\-\._\(\)]+$/)
      |> validate_format(:ip_addr, Util.ipv4_regex)
      |> validate_format(:mac_addr, Util.mac_regex)
      |> validate_unique(:name, on: Repo)
  end

  def create(params) do
    changeset = changeset(%Endpoint{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end

  def update(id, params) do
    changeset = changeset(Repo.get!(Endpoint, id), params)

    if changeset.valid? do
      Repo.update(changeset)
    end
  end
end

defmodule BorderProfile do
  use Ecto.Model

  schema "border_profiles" do
    field :name
    field :module
    field :description, :string, default: ""
    has_many :endpoint_to_border_profiles, EndpointToBorderProfile
    has_many :border_profiles,
      through: [:endpoint_to_border_profiles, :border_profile]
  end

  def changeset(border_profile, params \\ nil) do
    border_profile
      |> cast(params, ~w(name module), ~w(description))
      |> validate_format(:name, ~r/^[a-zA-Z0-9][a-zA-Z0-9\._ ]+$/)
      |> validate_format(:module, ~r/^[a-zA-Z0-9][a-zA-Z0-9\._]+$/)
      |> validate_format(:description,
        ~r/^[a-zA-Z0-9\-\._ <>,\[\]\{\}\|\\\/!@#\$%\^&\*\(\)\+=\?~`'":;]$/)
  end

  def create(params) do
    changeset = changeset(%BorderProfile{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end
end

defmodule EndpointToBorderProfile do
  use Ecto.Model

  schema "endpoint_to_border_profile" do
    belongs_to :endpoint, Endpoint
    belongs_to :border_profile, BorderProfile
  end

  def changeset(endpoint_to_profile, params \\ nil) do
    endpoint_to_profile
      |> cast(params, ~w(endpoint_id border_profile_id))
      |> validate_inclusion(:endpoint_id, 1..2147483647)
      |> validate_inclusion(:border_profile_id, 1..2147483647)
  end

  def create(params) do
    changeset = changeset(%EndpointToBorderProfile{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end

  def drop(endpoint_to_border_profile) do
    Repo.delete(endpoint_to_border_profile)
  end
end

defmodule EdgeInterfaceToEndpoint do
  use Ecto.Model

  schema "edge_interface_to_endpoint" do
    belongs_to :edge_interface, EdgeInterface
    belongs_to :endpoint, Endpoint
  end

  def changeset(edge_if_to_endpoint, params \\ nil) do
    edge_if_to_endpoint
      |> cast(params, ~w(edge_interface_id endpoint_id))
      |> validate_inclusion(:edge_interface_id, 1..2147483647)
      |> validate_inclusion(:endpoint_id, 1..2147483647)
      |> validate_unique(:endpoint_id, on: Repo)
  end

  def create(_id, params) do
    changeset = changeset(%EdgeInterfaceToEndpoint{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end
end

defmodule EdgeInterfaceToEdgeDevice do
  use Ecto.Model

  schema "edge_interface_to_edge_device" do
    belongs_to :edge_interface, EdgeInterface
    belongs_to :edge_device, EdgeDevice
  end

  def changeset(edge_if_to_edge_dev, params \\ nil) do
    edge_if_to_edge_dev
      |> cast(params, ~w(edge_interface_id edge_device_id))
      |> validate_inclusion(:edge_interface_id, 1..2147483647)
      |> validate_inclusion(:edge_device_id, 1..2147483647)
      |> validate_unique(:edge_interface_id, on: Repo)
  end

  def create(_id, params) do
    changeset = changeset(%EdgeInterfaceToEdgeDevice{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end
end

defmodule User do
  use Ecto.Model

  schema "users" do
    field :name, :string, size: 255
    has_many :jobs, Job
  end

  def changeset(user, params \\ nil) do
    user
      |> cast(params, ~w(name))
      |> validate_format(:name, ~r/^[a-zA-Z][a-zA-Z0-9\-\._]*$/)
      |> validate_unique(:name, on: Repo)
  end

  def create(_id, params) do
    changeset = changeset(%User{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end
end

defmodule Job do
  use Ecto.Model

  schema "jobs" do
    field :ticket, :integer
    belongs_to :edge_interface, EdgeInterface
    belongs_to :submitted_by, User
    field :created, Ecto.DateTime, default: Ecto.DateTime.utc
    field :ended, Ecto.DateTime
    field :result, :integer
  end

  def changeset(job, params \\ nil) do
    job
      |> cast(params, ~w(ticket edge_interface submitted_by created ended result))
      |> validate_inclusion(:ticket, 1..2147483647)
      |> validate_inclusion(:edge_interface, 1..2147483647)
      |> validate_inclusion(:submitted_by, 1..2147483647)
      |> validate_format(:created, Util.iso_8601_regex)
      |> validate_format(:ended, Util.iso_8601_regex)
      |> validate_inclusion(:result, 1..2147483647)
  end

  def create(_id, params) do
    changeset = changeset(%Job{}, params)

    if changeset.valid? do
      Repo.insert(changeset)
    end
  end

  def update(id, params) do
    changeset = changeset(Repo.get!(Job, id), params)

    if changeset.valid? do
      Repo.update(changeset)
    end
  end
end
