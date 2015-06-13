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

  resource :endpoints do
    get id do
      if endpoint = Repo.get_endpoint(id) do
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
        |> Repo.find_endpoints
        #|> Enum.map(fn s -> s |> Map.from_struct |> Map.delete(:__meta__) end)
        |> Enum.map(fn m ->
          %{id: m.id, name: m.name, ip: m.ip_addr, mac: m.mac_addr}
        end)
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
      Repo.assign_profiles(id, profiles)
        |> reply 200
    end

    post do
      if endpoint = Repo.add_endpoint(params["name"], params["ip"], params["mac"]) do
        endpoint.id |> reply 200
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
      cond do
        name = query["name"] ->
          Repo.find_edge_devices(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
        ip = query["ip"] ->
          Repo.find_edge_devices(ip: ip)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
      end
    end
  end

  resource :interfaces do
    get id do
      id
        |> Repo.get_edge_interface
        |> Map.from_struct
        |> reply 200
    end

    get do
      cond do
        name = query["name"] ->
          Repo.find_edge_interfaces(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
        true ->
          Repo.find_edge_interfaces(%{})
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
      end
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
          Repo.find_border_profiles(name: name)
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
        true ->
          Repo.find_border_profiles(%{})
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
          Repo.find_jobs(%{"ticket" => ticket})
            |> Enum.map(&(Map.from_struct &1))
            |> reply 200
        true ->
          Repo.find_jobs(%{})
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

