defmodule SNMP.CiscoTest do
  use ExUnit.Case, async: true

  import SNMP.Cisco

  test "cc_copy_entry returns correct CcCopyEntry" do
    assert cc_copy_entry(:tftp,
                         :network_file, :running_config,
                         "scrap.cfg", :ipv4, "192.0.2.1") ==
      %SNMP.Cisco.CcCopyEntry{
        ccCopyProtocol: 1,
        ccCopySourceFileType: 1,
        ccCopyDestFileType: 4,
        ccCopyFileName: "scrap.cfg",
        ccCopyServerAddressType: 1,
        ccCopyServerAddressRev1: "192.0.2.1",
        ccCopyEntryRowStatus: 4,
        ccCopyState: 1,
        ccCopyFailCause: 1
      }
  end
  test "cc_copy_entry fails for incorrect protocol" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:blarg, :network_file, :running_config, "scrap.cfg", :ipv4, "192.0.2.1")
    end
  end
  test "cc_copy_entry fails for incorrect source file type" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:tftp, :blarg, :running_config, "scrap.cfg", :ipv4, "192.0.2.1")
    end
  end
  test "cc_copy_entry fails for incorrect destination file type" do
    assert_raise KeyError, fn ->
      cc_copy_entry(:tftp, :network_file, :blarg, "scrap.cfg", :ipv4, "192.0.2.1")
    end
  end

  test "cc_copy_entry_to_snmp_objects returns correct list of SNMP.Objects" do
    test_entry = %SNMP.Cisco.CcCopyEntry{
      ccCopyProtocol: 1,
      ccCopySourceFileType: 1,
      ccCopyDestFileType: 4,
      ccCopyFileName: "scrap.cfg",
      ccCopyServerAddressType: 1,
      ccCopyServerAddressRev1: "192.0.2.1",
      ccCopyEntryRowStatus: 4,
      ccCopyState: 1,
      ccCopyFailCause: 1
    }

    assert cc_copy_entry_to_snmp_objects(test_entry, 1) ==
      [
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,2,1], type: 2, value: 1},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,3,1], type: 2, value: 1},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,4,1], type: 2, value: 4},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,6,1], type: 4, value: "scrap.cfg"},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,15,1], type: 2, value: 1},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,16,1], type: 4, value: "192.0.2.1"},
        %SNMP.Object{oid: [1,3,6,1,4,1,9,9,96,1,1,1,1,14,1], type: 2, value: 4}
      ]
  end
end

