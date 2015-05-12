# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Director do
  use GenServer

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
    temp_path = Path.join(System.tmp_dir!, filename)

    try do
      false = File.exists?(temp_path)
    rescue
      _ in MatchError ->
        raise File.Error,
          exception: "Temp file already exists: #{filename}.cfg"
    end

    temp_path
  end

  defp execute_job(job, tftp_server, snmp_credential) do
    edge_if = Repo.get_edge_interface(job.edge_interface.id)
    edge_dev = edge_if.edge_device
    cfg_file_name = "#{edge_dev.ip_addr}.cfg"

    cfg_local_path = get_temp_file(cfg_file_name)

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

    generate_configuration(accept, offer, edge_if.name)
      |> BorderPatrol.IO.write_to_file!(cfg_local_path)
    
    :ok = TFTP.put(cfg_local_path, tftp_server, :binary)
    
    snmp_agent = NetSNMP.agent(edge_dev.ip_addr)
    CiscoSNMP.copy_tftp_run(tftp_server, cfg_file_name, snmp_agent, snmp_credential)
    CiscoSNMP.copy_run_start(snmp_agent, snmp_credential)
    
    File.rm! cfg_local_path
  end

  defp start_job(job) do
    Repo.update(%{job|started: Ecto.DateTime.utc})
  end

  defp end_job(job, result) do
    Repo.update(%{job|ended: Ecto.DateTime.utc, result: result})
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

  defp watch_jobs(tftp_server, snmp_credential) do
    job = get_next_job |> start_job
    try do
      execute_job(job, tftp_server, snmp_credential)
      end_job(job, 0)
    rescue
      _ -> end_job(job, 1)
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