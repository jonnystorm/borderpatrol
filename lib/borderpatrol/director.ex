defmodule BorderPatrol.Director do
  defp execute_job(job) do
    #edge_if = Repo.all(from e in EdgeInterface, select: e, where: e.id == ^job.edge_if)
    #edge_dev = edge_if.edge_device.ip_addr
    #filename = System.tmp_dir! <> "#{edge_dev}.cfg"
    #check if filename exists
    #
    #[accept, offer] = edge_if.endpoints
    #  |> Enum.map(fn e ->
    #    quoted_module = {:__aliases__, [alias: false], [String.to_atom(e.profile.module)]}
    #    {module, _} = Code.eval_quoted(quoted_module)
    #    acls = module.generate_acls(e.ip_addr, edge_if, edge_dev, e.name)
    #    
    #    {acls[:accept], acls[:offer]}
    #  end)
    #  |> Enum.reduce({ACL.new(4), ACL.new(4)}, fn({a1, o1}, {a2, o2}) ->
    #    {ACL.concat(a1, a2), ACL.concat(o1, o2)}
    #  end)
    #
    #"""
    ##{accept}
    ##{offer}
    #
    #interface #{edge_if}
    # access-policy input #{accept.name}
    # access-policy output #{offer.name}
    #end 
    #""" |> BorderPatrol.IO.write_to_file!(filename)
    #
    #:ok = TFTP.put(file, tftp_server, :binary)
    #
    #snmp_agent = SNMP.agent(edge_dev.ip_addr, :udp, 161)
    #snmp_cred = SNMP.credential(:v2c, "cisco")
    #
    #SNMP.Cisco.copy_tftp_run(tftp_server, filename, snmp_agent, snmp_cred)
    #
    #delete filename
  end
end
