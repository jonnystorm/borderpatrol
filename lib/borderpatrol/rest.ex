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
  ], adapters: [BorderPatrol.APIv1, Urna.JSON, Urna.Form]

  alias BorderPatrol.Repo, as: Repo

  require Logger

  resource :provision do
    post do
      endpoint = Repo.find_endpoints(params["endpointName"])
      || Repo.add_endpoint(
        params["endpointName"],
        params["endpointIp"],
        params["endpointMac"]
      )
      profile = Repo.get_border_profile(params["borderProfile"])
      edge_dev = Repo.get_edge_device(params["edgeDevice"])
      edge_if = Repo.get_edge_interface(params["edgeInterface"])

      Repo.assign_profiles(endpoint, profile)
    end
  end

  defp endpoint_to_endpoint_entry(endpoint) do
    %{
        endpoint_id: endpoint.endpoint.id,
      endpoint_name: endpoint.endpoint.name,
        endpoint_ip: endpoint.endpoint.ip_addr,
       endpoint_mac: endpoint.endpoint.mac_addr,
         profile_id: endpoint.border_profile.id,
       profile_name: endpoint.border_profile.name
    }
  end

  resource :endpoints do
    get id do
      if endpoint = Repo.get_endpoint(id) do
        endpoint_to_endpoint_entry(endpoint) |> reply 200
      else
        fail 404
      end
    end

    get do
      (uri.query && query || %{})
      |> Enum.filter(fn p -> p in ["name", "ip", "mac"] end)
      |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
      |> Repo.find_endpoints
      |> Enum.map(fn e -> endpoint_to_endpoint_entry e end)
      |> reply 200
    end

    put id do
      (for {k, v} <- params, into: %{}, do: {String.to_atom(k), v})
      |> Repo.update_endpoint(id)

      profiles = params
      |> Enum.reduce([], fn
        ({"profile", v}, acc) ->
          [v|acc]

        (_, acc) ->
          acc
      end)

      Repo.assign_profiles(id, profiles) |> reply 200
    end

    post do
      if endpoint = Repo.add_endpoint(params["name"], params["ip"], params["mac"]) do
        reply endpoint.id 200
      else
        fail 400
      end
    end
  end

  resource :devices do
    get id do
      id
      |> Repo.get_edge_device
      |> Map.from_struct
      |> reply 200
    end

    get do
      (uri.query && query || %{})
      |> Enum.filter(fn p -> p in ["name", "ip"] end)
      |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
      |> Repo.find_edge_devices
      |> reply 200
    end
  end

  defp interface_to_edge_entry(interface) do
    %{
           device_id: interface.edge_device.id,
         device_name: interface.edge_device.hostname,
           device_ip: interface.edge_device.ip_addr,
        interface_id: interface.edge_interface.id,
      interface_name: interface.edge_interface.name
    }
  end

  resource :interfaces do
    get id do
      if interface = Repo.get_edge_interface(id) do
        interface_to_edge_entry(interface) |> reply 200
      else
        fail 404
      end
    end

    get do
      (uri.query && query || %{})
      |> Enum.filter(fn p -> p in ["name", "ip"] end)
      |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
      |> Repo.find_edge_interfaces
      |> Enum.map(fn i -> interface_to_edge_entry i end)
      |> reply 200
    end
  end

  resource :profiles do
    get id do
      id
      |> Repo.get_border_profile
      |> Map.from_struct
      |> reply 200
    end

    get do
      cond do
        name = query["name"] ->
          [name: name]
          |> Repo.find_border_profiles
          |> Enum.map(&(Map.from_struct &1))
          |> reply 200
        true ->
          %{}
          |> Repo.find_border_profiles
          |> Enum.map(&(Map.from_struct &1))
          |> reply 200
      end
    end
  end

  resource :jobs do
    get id do
      id
      |> Repo.get_job
      |> Map.from_struct
      |> reply 200
    end

    get do
      cond do
        ticket = query["ticket"] ->
          %{"ticket" => ticket}
          |> Repo.find_jobs
          |> Enum.map(&(Map.from_struct &1))
          |> reply 200
        true ->
          %{}
          |> Repo.find_jobs
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

