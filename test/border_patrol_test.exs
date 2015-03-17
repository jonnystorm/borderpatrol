# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrolTest do
  use ExUnit.Case

  def await_copy_result(row, agent, credential) do
    copy_state_oid = "1.3.6.1.4.1.9.9.96.1.1.1.1.10.#{row}"

    case SNMP.get(copy_state_oid, agent, credential) do
      "INTEGER: 3" ->
        :ok
      "INTEGER: 4" ->
        fail_cause_oid = "1.3.6.1.4.1.9.9.96.1.1.1.1.13.#{row}"
        fail_cause = SNMP.get(fail_cause_oid, agent, credential)

        {:error, SNMP.Cisco.CcCopyEntry.number_to_copy_fail_cause(fail_cause)}
      _ ->
        :timer.sleep 1000
        await_copy_result(row, agent, credential)
    end
  end

  test "all the things" do
    import ACL, only: [permit: 4, permit: 5, permit: 6, deny: 4, deny: 5, deny: 6]

    # TODO: Fix collision between (Test ACL -> test_acl) and (test_acl -> test_acl)
    acl = ACL.new(4, "Test ACL")
      |> permit(:tcp, "192.0.2.0/24", "192.0.2.4/32", eq: 443)
      |> deny(:icmp, "192.0.2.1/32", "192.0.2.4/32")

    {:ok, file} = File.open "/tmp/scrap.cfg", [:write]
    :ok = IO.binwrite file, to_string(acl)
    :ok = File.close file

    # Must first cd to /tmp
    :ok = TFTP.put "/tmp/scrap.cfg", "192.0.2.1", :binary

    test_agent = SNMP.agent("192.0.2.2", :udp, 161)
    test_cred = SNMP.credential(:v2c, "cisco")
    test_row = 1
    row_status_oid = "1.3.6.1.4.1.9.9.96.1.1.1.1.14"

    SNMP.Cisco.cc_copy_entry(:tftp,
        :network_file,
        :running_config,
        "scrap.cfg",
        :ipv4, "192.0.2.1"
    ) |> SNMP.Cisco.cc_copy_entry_to_snmp_objects(test_row)
      |> SNMP.set(test_agent, test_cred)
      |> IO.inspect

    IO.inspect await_copy_result(test_row, test_agent, test_cred)

    [SNMP.object("#{row_status_oid}.#{test_row}", :integer, 6)]
      |> SNMP.set(test_agent, test_cred)
  end
end
