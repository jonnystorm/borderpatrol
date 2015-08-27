# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Director do
  use GenServer

  require Logger

  alias BorderPatrol.Repo, as: Repo

  defp generate_acls(endpoints) do
    for e <- endpoints, p <- e.border_profiles do
      {module, _} = Code.eval_string(p.module)

      module.generate_acl(e.ip_addr)
    end
  end

  defp generate_configuration(accept_acl, offer_acl, if_name) do
    """
    #{accept_acl}
    #{offer_acl}
    
    interface #{if_name}
     ip access-group #{accept_acl.name} in
     ip access-group #{offer_acl.name} out

    end
    """
  end

  defp get_temp_file(filename) do
    Path.join(System.tmp_dir!, filename)
  end

  defp execute_job(job, tftp_server, snmp_credential) do
    edge_if = Repo.get_edge_interface(job.edge_interface.id)
    edge_dev = edge_if.edge_device

    acl_base_name = edge_if.name
    |> String.replace("/", "_")
    |> String.downcase

    accept = edge_if.endpoints
    |> generate_acls
    |> ACL.concat
    |> ACL.name("bp_#{acl_base_name}_accept")

    offer = accept
    |> ACL.reflect
    |> ACL.name("bp_#{acl_base_name}_offer")

    cfg_file_name = "#{edge_dev.ip_addr}.cfg"
    cfg_local_path = get_temp_file(cfg_file_name)

    generate_configuration(accept, offer, edge_if.name)
    |> BorderPatrol.IO.write_to_file!(cfg_local_path, [:exclusive])
    
    :ok = TFTP.put(cfg_local_path, tftp_server, :binary)
    File.rm! cfg_local_path
    
    snmp_agent = Pathname.new(edge_dev.ip_addr)
    CiscoSNMP.copy_tftp_run(tftp_server, cfg_file_name, snmp_agent, snmp_credential)
    CiscoSNMP.copy_run_start(snmp_agent, snmp_credential)
  end

  defp start_job(job) do
    Repo.update!(%{job|started: Ecto.DateTime.utc})
  end

  defp end_job(job, result) do
    Repo.update!(%{job|ended: Ecto.DateTime.utc, result: result})
  end

  defp get_next_job do
    :timer.sleep(1000)

    case Repo.find_unstarted_jobs do
      [job|_] ->
        job
      _ ->
        get_next_job
    end
  end

  defp receive_down do
    receive do
      {:DOWN, _, _, _, result} ->
        result
      _ ->
        nil
    end
  end

  defp watch_jobs(tftp_server, snmp_credential) do
    job = get_next_job |> start_job
    spawn_monitor fn -> execute_job(job, tftp_server, snmp_credential) end

    case receive_down do
      :normal ->
        end_job job, 0

      # a configuration file of the same name already exists
      {%File.Error{reason: :eexist}, _} ->
        end_job job, 2

      # TFTP connection timed out
      {{:badmatch, {:error, :etimedout}}, _} ->
        end_job job, 3

      # the configuration file does not exist on the TFTP server
      {{:badmatch, {:error, :enoent}}, _} ->
        end_job job, 4

      # the TFTP server does not have correct permissions set
      {{:badmatch, {:error, "Error code 0: Permission denied"}}, _} ->
        end_job job, 5

      # unable to set copy entry row status
      {{:badmatch, {:error, :snmp_err_wrongvalue}}, _} ->
        end_job job, 6

      # an SNMP operation failed
      {{:badmatch, []}, _} ->
        end_job job, 7

      msg ->
        Logger.warn "Received unknown error from job #{job.id}: #{inspect msg}"

        end_job job, 1
    end

    watch_jobs(tftp_server, snmp_credential)
  end

  def handle_cast(:start, _state) do
    opts = Application.get_env(:borderpatrol, BorderPatrol.Director, [])
    tftp_server = opts[:tftp_server]
    snmp_credential = opts[:snmp_credential]

    watch_jobs(tftp_server, snmp_credential)

    {:noreply, {}}
  end

  def start_link do
    result = GenServer.start_link(__MODULE__, [], [name: :director])
    GenServer.cast(:director, :start)

    result
  end
end
