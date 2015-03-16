# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule ACLTest do
  use ExUnit.Case, async: true

  import ACL #, only: [permit: 4, permit: 5, permit: 6, deny: 4, deny: 5, deny: 6]

  test "to_string returns correct string from ACL" do
    test_acl = ACL.new(4, "Test ACL")
      |> permit(:tcp, "192.0.2.0/24", "192.0.2.4/32", eq: 443)
      |>   deny(:icmp, "192.0.2.1/32", "192.0.2.4/32")
  
    assert to_string(test_acl) == ("""
    ip access-list extended test_acl
      permit tcp 192.0.2.0 0.0.0.255 192.0.2.4 0.0.0.0 eq 443
      deny icmp 192.0.2.1 0.0.0.0 192.0.2.4 0.0.0.0
    """)
  end
end
