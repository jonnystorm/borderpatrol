# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule SNMPTest do
  use ExUnit.Case, async: true

  test "agent returns correct Agent" do
    assert SNMP.agent("192.0.2.1", :udp, 161)
      == %SNMP.Agent{host: "192.0.2.1", proto: :udp, port: 161}
  end
  test "agent fails for invalid protocol" do
    assert_raise FunctionClauseError, fn ->
      SNMP.agent("192.0.2.1", :blarg, 161)
    end
  end
  
  test "oid_list_to_string returns correct string" do
    assert SNMP.Object.oid_list_to_string([1,3,6,0,9,20,1]) == "1.3.6.0.9.20.1"
  end

  test "oid_string_to_list returns correct list" do
    assert SNMP.Object.oid_string_to_list("1.3.6.0.9.20.1") == [1,3,6,0,9,20,1]
  end
  test "oid_string_to_list returns correct list from OID with leading dot" do
    assert SNMP.Object.oid_string_to_list(".1.3.6.0.9.20.1") == [1,3,6,0,9,20,1]
  end
  test "oid_string_to_list returns correct list from OID with trailing dot" do
    assert SNMP.Object.oid_string_to_list("1.3.6.0.9.20.1.") == [1,3,6,0,9,20,1]
  end
  test "oid_string_to_list returns correct list from OID with leading/trailing dots" do
    assert SNMP.Object.oid_string_to_list(".1.3.6.0.9.20.1.") == [1,3,6,0,9,20,1]
  end

  test "object returns correct SNMP.Object with integer" do
    assert SNMP.object("1.3.6.0.9.20.1", :integer, 1) ==
      %SNMP.Object{
        oid: [1,3,6,0,9,20,1],
        type: 2,
        value: 1
      }
  end
  test "object returns correct SNMP.Object with octet_string" do
    assert SNMP.object("1.3.6.0.9.20.1", :octet_string, "") ==
      %SNMP.Object{
        oid: [1,3,6,0,9,20,1],
        type: 4,
        value: ""
      }
  end
  test "object fails for invalid type" do
    assert_raise KeyError, fn ->
      SNMP.object("1.3.6.0.9.20.1", :blarg, 1)
    end
  end

  test "credential returns correct keyword list for SNMPv2c" do
    assert SNMP.credential(:v2c, "ancommunity") ==
      [version: "2c", community: "ancommunity"]
  end
  test "credential returns correct keyword list for SNMPv3, noAuthNoPriv" do
    assert SNMP.credential(:v3, :no_auth_no_priv, "anname") ==
      [version: "3", sec_level: "noAuthNoPriv", sec_name: "anname"]
  end
  test "credential returns correct keyword list for SNMPv3, authNoPriv" do
    assert SNMP.credential(:v3, :auth_no_priv, "anname", :md5, "anpass") ==
      [
        version: "3",
        sec_level: "authNoPriv",
        sec_name: "anname",
        auth_proto: "md5",
        auth_pass: "anpass"
      ]
  end
  test "credential returns correct keyword list for SNMPv3, authPriv" do
    assert SNMP.credential(:v3, :auth_priv, "anname", :sha, "anpass", :des, "anpass2") ==
      [
        version: "3",
        sec_level: "authPriv",
        sec_name: "anname",
        auth_proto: "sha",
        auth_pass: "anpass",
        priv_proto: "des",
        priv_pass: "anpass2"
      ]
  end
  test "credential fails for invalid security level" do
    assert_raise FunctionClauseError, fn ->
      SNMP.credential(:v3, :blarg, "anname", :sha, "anpass", :des, "anpass2")
    end
  end
  test "credential fails for invalid authentication protocol" do
    assert_raise FunctionClauseError, fn ->
      SNMP.credential(:v3, :auth_priv, "anname", :blarg, "anpass", :des, "anpass2")
    end
  end
  test "credential fails for invalid privacy protocol" do
    assert_raise FunctionClauseError, fn ->
      SNMP.credential(:v3, :auth_priv, "anname", :sha, "anpass", :blarg, "anpass2")
    end
  end

  test "credential_to_snmpcmd_args returns correct string" do
    test_creds = [
      version: "3",
      sec_level: "authPriv",
      sec_name: "anname",
      auth_proto: "sha",
      auth_pass: "anpass",
      priv_proto: "aes",
      priv_pass: "anpass2"
    ]

    assert SNMP.credential_to_snmpcmd_args(test_creds) ==
      "-v3 -lauthPriv -u anname -a sha -A anpass -x aes -X anpass2"
  end

  test "to_string returns correct string for Agent" do
    assert to_string(SNMP.agent("192.0.2.1", :udp, 161)) == "udp:192.0.2.1:161"
  end

  test "to_string returns correct string for Object of type integer" do
    assert to_string(SNMP.object("1.3.6.0.9.20.1", :integer, 1)) == "1.3.6.0.9.20.1 i 1"
  end
  test "to_string returns correct string for Object of type octet string" do
    assert to_string(SNMP.object("1.3.6.0.9.20.1", :octet_string, 1)) == "1.3.6.0.9.20.1 s 1"
  end
end
