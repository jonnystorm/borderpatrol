defmodule SNMP.CiscoTest do
  use ExUnit.Case, async: true

  import SNMP.Cisco

  test "cc_copy_entry fails for incorrect protocol" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:blarg,
        :network_file, :running_config, "scrap.cfg",
        :ipv4, "192.0.2.1"
      )
    end
  end
  test "cc_copy_entry fails for incorrect source file type" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:tftp,
        :blarg, :running_config, "scrap.cfg",
        :ipv4, "192.0.2.1"
      )
    end
  end
  test "cc_copy_entry fails for incorrect destination file type" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:tftp,
        :network_file, :blarg, "scrap.cfg",
        :ipv4, "192.0.2.1"
      )
    end
  end
end

