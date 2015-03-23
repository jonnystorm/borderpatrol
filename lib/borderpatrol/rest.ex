# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.REST do
  use Urna, allow: [
    headers: true,
    methods: true,
    credentials: true,
    origins: ["http://localhost:8888"]
  ], adapters: [Urna.JSON, Urna.Form]

  import Ecto.Query

  defp add_endpoint(name, ip, mac) do
    Endpoint.create(%{name: name, ip_addr: ip, mac_addr: mac})
  end

  defp get_endpoint(id) do
    query = from e in Endpoint,
      where: e.id == ^id,
      select: e,
      preload: :border_profiles
    [endpoint] = Repo.all(query)

    endpoint
  end

  defp find_endpoints(params) do
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

  defp update_endpoint(params, id) do
    Endpoint.update(id, params)
  end

  defp unassign_profiles(endpoint, profiles) do
    profiles
      |> Enum.reduce(fn(p, acc) ->
        acc ++ find_endpoint_to_border_profiles(
          [endpoint_id: endpoint.id, border_profile_id: p.id]
        )
      end)
      |> Enum.map(&(EndpointToBorderProfile.drop &1))
  end

  defp assign_profiles(endpoint, profiles) do
    profiles
      |> Enum.map(fn p ->
        EndpointToBorderProfile.create(
          %{endpoint_id: endpoint.id, border_profile_id: p.id}
        )
      end)
  end

  defp get_border_profile(id) do
    query = from e in Endpoint,
      where: e.id == ^id,
      select: e
    [endpoint] = Repo.all(query)

    endpoint
  end

  defp get_edge_device(id) do
    query = from e in EdgeDevice,
      where: e.id == ^id,
      select: e
    [edge_device] = Repo.all(query)

    edge_device
  end

  defp get_edge_interface(id) do
    query = from e in EdgeInterface,
      where: e.id == ^id,
      select: e
    [edge_interface] = Repo.all(query)

    edge_interface
  end

  defp find_edge_devices(params) do
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

  defp find_edge_interfaces(params) do
    query = from e in EdgeInterface

    if name = params["name"] do
      query = from e in query, where: e.name == ^name
    end

    query = from e in query, select: e

    Repo.all(query)
  end

  defp find_border_profiles(params) do
    query = from p in BorderProfile

    if name = params["name"] do
      query = from p in query, where: p.name == ^name
    end
    
    query = from p in query, select: p

    Repo.all(query)
  end

  defp get_endpoint_to_border_profile(id) do
    query = from e in EndpointToBorderProfile,
      where: e.id == ^id,
      select: e
    [e_to_bp] = Repo.all(query)

    e_to_bp
  end

  defp find_endpoint_to_border_profiles(params) do
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

  resource :provision do
    post do
      endpoint = find_endpoints(params["endpointName"])
        || add_endpoint(
          params["endpointName"],
          params["endpointIp"],
          params["endpointMac"]
        )
      profile = get_border_profile(params["borderProfile"])
      edge_dev = get_edge_device(params["edgeDevice"])
      edge_if = get_edge_interface(params["edgeInterface"])

      assign_profiles(endpoint, profile)
    end
  end

  resource :endpoints do
    get id do
      if endpoint = get_endpoint(id) do
        endpoint
          |> (fn s -> s |> Map.from_struct |> Map.delete(:__meta__) end).()
          |> (fn m ->
            %{id: m.id, name: m.name, ip: m.ip_addr, mac: m.mac_addr}
          end).()
          |> reply 200
      else
        fail 404
      end
    end

    get do
      params = uri.query && query || %{}

      params
        |> find_endpoints
        |> Enum.map(fn s -> s |> Map.from_struct |> Map.delete(:__meta__) end)
        |> Enum.map(fn m ->
          %{id: m.id, name: m.name, ip: m.ip_addr, mac: m.mac_addr}
        end)
        |> reply 200
    end

    put id do
      (for {k, v} <- params, into: %{}, do: {String.to_atom(k), v})
        |> update_endpoint(id)
      profiles = params
        |> Enum.reduce([], fn
          ({"profile", v}, acc) ->
            [v|acc]
          (_, acc) ->
            acc
        end)
      assign_profiles(id, profiles)
        |> reply 200
    end

    post do
      if endpoint = add_endpoint(params["name"], params["ip"], params["mac"]) do
        endpoint.id |> reply 200
      else
        fail 400
      end
    end
  end

  resource :edge_devices do
    get id do
      id
        |> get_edge_device
        |> Map.from_struct
        |> reply 200
    end

    get do
      cond do
        name = query["name"] ->
          find_edge_devices(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
        ip = query["ip"] ->
          find_edge_devices(ip: ip)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
      end
    end
  end

  resource :edge_interfaces do
    get id do
      id
        |> get_edge_interface
        |> Map.from_struct
        |> reply 200
    end

    get do
      cond do
        name = query["name"] ->
          find_edge_interfaces(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
      end
    end
  end

  resource :profiles do
    get id do
      id
        |> get_border_profile
        |> Map.from_struct
        |> reply 200
    end

    get do
      cond do
        name = query["name"] ->
          find_border_profiles(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
      end
    end
  end

  def start_link do
    port = Application.get_env(:borderpatrol, BorderPatrol.REST, [])[:port]

    Urna.start BorderPatrol.REST, port: port
  end
end

