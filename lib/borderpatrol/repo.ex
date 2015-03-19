defmodule BorderPatrol.Repo do
  use Ecto.Repo, otp_app: :borderpatrol
end

defmodule EdgeDevice do
  use Ecto.Model

  schema "edge_devices" do
    field :hostname
    field :ip_addr
    has_many :edge_interface_to_edge_device, EdgeInterfaceToEdgeDevice
  end

  def changeset(edge_device, params \\ nil) do
    edge_device
      |> cast(params, ~w(hostname ip_addr))
      #|> validate_format(:hostname, ~r/^[a-zA-Z0-9][a-zA-Z0-9\-\._]*$/)
      #|> validate_format(:ip_addr, Util.ipv4_regex)
      #|> validate_unique(:hostname, on: BorderPatrol.Repo)
      #|> validate_unique(:ip_addr, on: BorderPatrol.Repo)
  end

  def create(_id, params) do
    changeset = change(%EdgeDevice{}, params[:edge_device])

    case changeset.valid? do
      true ->
        BorderPatrol.Repo.insert(changeset)
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
    has_one :edge_interface_to_border_profile, EdgeInterfaceToBorderProfile
    has_one :edge_interface_to_endpoint, EdgeInterfaceToEndpoint
    has_many :endpoints,
      through: [:edge_interface_to_endpoint, :endpoint]
    has_many :jobs, Job
  end

  def changeset(edge_interface, params \\ nil) do
    edge_interface
      |> cast(params, ~w(name))
      |> validate_format(:name, ~r/^[a-zA-Z0-9\-\._]+$/)
      |> validate_unique(:name, on: BorderPatrol.Repo)
  end
end

defmodule Endpoint do
  use Ecto.Model

  schema "endpoints" do
    field :name
    field :ip_addr
    field :mac_addr
    has_one :endpoint_to_border_profile, EndpointToBorderProfile
    has_one :edge_interface_to_endpoint, EdgeInterfaceToEndpoint
    has_one :border_profile,
      through: [:endpoint_to_border_profile, :border_profile]
    has_one :edge_interface,
      through: [:edge_interface_to_endpoint, :edge_interface]
  end

  def changeset(endpoint, params \\ nil) do
    endpoint
      |> cast(params, ~w(name ip_addr mac_addr))
      |> validate_format(:name, ~r/^[a-zA-Z0-9\-\._\(\)]+$/)
      |> validate_format(:ip_addr, Util.ipv4_regex)
      |> validate_format(:mac_addr, Util.mac_regex)
      |> validate_unique(:name, on: BorderPatrol.Repo)
  end
end

defmodule BorderProfile do
  use Ecto.Model

  schema "border_profiles" do
    field :name
    field :module
    field :description, :string, default: ""
    has_many :endpoint_to_border_profile, EndpointToBorderProfile
    has_many :edge_interface_to_border_profile, EdgeInterfaceToBorderProfile
  end

  def changeset(border_profile, params \\ nil) do
    border_profile
      |> cast(params, ~w(name module), ~w(description))
      |> validate_format(:name, ~r/^[a-zA-Z0-9][a-zA-Z0-9\._ ]+$/)
      |> validate_format(:module, ~r/^[a-zA-Z0-9][a-zA-Z0-9\._]+$/)
      |> validate_format(:description,
        ~r/^[a-zA-Z0-9\-\._ <>,\[\]\{\}\|\\\/!@#\$%\^&\*\(\)\+=\?~`'":;]$/)
  end
end

defmodule EndpointToBorderProfile do
  use Ecto.Model

  schema "endpoint_to_border_profile" do
    belongs_to :endpoint, Endpoint
    belongs_to :border_profile, BorderProfile
  end
end

defmodule EdgeInterfaceToEndpoint do
  use Ecto.Model

  schema "edge_interface_to_endpoint" do
    belongs_to :edge_interface, EdgeInterface
    belongs_to :endpoint, EndPoint
  end
end

defmodule EdgeInterfaceToEdgeDevice do
  use Ecto.Model

  schema "edge_interface_to_edge_device" do
    belongs_to :edge_interface, EdgeInterface
    belongs_to :edge_device, EdgeDevice
  end
end

defmodule User do
  use Ecto.Model

  schema "users" do
    field :name, :string, size: 255
  end
end

defmodule Job do
  use Ecto.Model

  schema "jobs" do
    field :ticket, :integer
    belongs_to :edge_interface, EdgeInterface
    belongs_to :submitted_by, Users
    field :created, Ecto.DateTime, default: Ecto.DateTime.utc
    field :ended, Ecto.DateTime
    field :result, :integer
  end
end
