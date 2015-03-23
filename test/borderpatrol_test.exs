# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrolTest do
  use ExUnit.Case

  #test "all the things" do
  #  import ACL, only: [permit: 4, permit: 5, permit: 6, deny: 4, deny: 5, deny: 6]

  #  # TODO: Fix collision between (Test ACL -> test_acl) and (test_acl -> test_acl)
  #  acl = ACL.new(4, "Test ACL")
  #    |> permit(:tcp, "192.0.2.0/24", "192.0.2.4/32", eq: 443)
  #    |> deny(:icmp, "192.0.2.1/32", "192.0.2.4/32")

  #  file = "/tmp/192.0.2.2.cfg"

  #  """
  #  #{acl}
  #  end
  #  """ |> BorderPatrol.IO.write_to_file!(file)

  #  :ok = TFTP.put(file, "192.0.2.1", :binary)

  #  test_agent = SNMP.agent("192.0.2.2", :udp, 161)
  #  test_cred = SNMP.credential(:v2c, "cisco")

  #  SNMP.Cisco.copy_tftp_run("192.0.2.1", "scrap.cfg", test_agent, test_cred)
  #end
end
