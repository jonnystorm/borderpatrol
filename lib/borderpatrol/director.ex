defmodule BorderPatrol.Director do
  def execute_job(job) do
    edge_if = Repo.get_edge_interface(job.edge_interface)
    edge_dev = edge_if.edge_device
    cfg_scrap_file = Path.join(System.tmp_dir!, "#{edge_dev.ip_addr}.cfg")
    false = File.exists?(cfg_scrap_file)

    [accept, offer] = (for e <- edge_if.endpoints, p <- e.border_profiles do
      {module, _} = Code.eval_string(p.module)
      acls = module.generate_acls(e.ip_addr, e.name)
    
      {acls[:accept], acls[:offer]}
    end)
    |> Enum.reduce({ACL.new(4), ACL.new(4)}, fn({a1, o1}, {a2, o2}) ->
      {ACL.concat(a1, a2), ACL.concat(o1, o2)}
    end)
    
    """
    #{accept}
    #{offer}
    
    interface #{edge_if}
     access-policy input #{accept.name}
     access-policy output #{offer.name}
    end 
    """ |> BorderPatrol.IO.write_to_file!(cfg_scrap_file)
    
    :ok = TFTP.put(cfg_scrap_file, 'localhost', :binary)
    
    #snmp_agent = NetSNMP.agent(edge_dev.ip_addr, :udp, 161)
    #snmp_cred = NetSNMP.credential(:v2c, "cisco")
    #
    #CiscoSNMP.copy_tftp_run(tftp_server, filename, snmp_agent, snmp_cred)
    #
    #File.rm! cfg_scrap_file
  end
end
