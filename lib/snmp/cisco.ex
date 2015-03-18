# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule SNMP.Cisco do
  defmodule CcCopyEntry do
    defstruct [
      ccCopyProtocol: nil,
      ccCopySourceFileType: nil,
      ccCopyDestFileType: nil,
      ccCopyFileName: nil,
      ccCopyUserName: nil,
      ccCopyUserPassword: nil,
      ccCopyNotificationOnCompletion: nil,
      ccCopyState: nil,
      ccCopyTimeStarted: nil,
      ccCopyTimeCompleted: nil,
      ccCopyFailCause: nil,
      ccCopyEntryRowStatus: nil,
      ccCopyServerAddressType: nil,
      ccCopyServerAddressRev1: nil
    ]
    @type t :: %CcCopyEntry{
      ccCopyProtocol: 1..5,
      ccCopySourceFileType: 1..6,
      ccCopyDestFileType: 1..6,
      ccCopyFileName: String.t,
      ccCopyUserName: String.t,
      ccCopyUserPassword: String.t,
      ccCopyNotificationOnCompletion: 1..2,
      ccCopyState: 1..4,
      ccCopyTimeStarted: String.t,
      ccCopyTimeCompleted: String.t,
      ccCopyFailCause: 1..9,
      ccCopyEntryRowStatus: 1..6,
      ccCopyServerAddressType: 0..4 | 16,
      ccCopyServerAddressRev1: String.t
    }

    def typeConfigCopyProtocol do
      %{
        tftp: 1,
        ftp: 2,
        rcp: 3,
        scp: 4,
        sftp: 5
      }
    end
    def typeConfigCopyProtocol(value) when is_atom(value) do
      typeConfigCopyProtocol[value]
    end
    def typeConfigCopyProtocol(value) when is_integer(value) do
      Util.get_key_by_value(typeConfigCopyProtocol, value)
    end

    def typeConfigFileType do
      %{
        network_file: 1,
        ios_file: 2,
        startup_config: 3,
        running_config: 4,
        terminal: 5,
        fabric_startup_config: 6
      }
    end
    def typeConfigFileType(value) when is_atom(value) do
      typeConfigFileType[value]
    end
    def typeConfigFileType(value) when is_integer(value) do
      Util.get_key_by_value(typeConfigFileType, value)
    end

    def typeInetAddressType do
      %{
        unknown: 0,
        ipv4: 1,
        ipv6: 2,
        ipv4z: 3,
        ipv6z: 4,
        dns: 16
      }
    end
    def typeInetAddressType(value) when is_atom(value) do
      typeInetAddressType[value]
    end
    def typeInetAddressType(value) when is_integer(value) do
      Util.get_key_by_value(typeInetAddressType, value)
    end

    def typeConfigCopyState do
      %{
        waiting: 1,
        running: 2,
        successful: 3,
        failed: 4
      }
    end
    def typeConfigCopyState(value) when is_atom(value) do
      typeConfigCopyState[value]
    end
    def typeConfigCopyState(value) when is_integer(value) do
      Util.get_key_by_value(typeConfigCopyState, value)
    end

    def typeConfigCopyFailCause do
      %{
        unknown: 1,
        bad_file_name: 2,
        timeout: 3,
        no_mem: 4,
        no_config: 5,
        unsupported_protocol: 6,
        some_config_apply_failed: 7,
        system_not_ready: 8,
        request_aborted: 9
      }
    end
    def typeConfigCopyFailCause(value) when is_atom(value) do
      typeConfigCopyFailCause[value]
    end
    def typeConfigCopyFailCause(value) when is_integer(value) do
      Util.get_key_by_value(typeConfigCopyFailCause, value)
    end

    def typeRowStatus do
      %{
        active: 1,
        not_in_service: 2,
        not_ready: 3,
        create_and_go: 4,
        create_and_wait: 5,
        destroy: 6
      }
    end
    def typeRowStatus(value) when is_atom(value) do
      typeRowStatus[value]
    end
    def typeRowStatus(value) when is_integer(value) do
      Util.get_key_by_value(typeRowStatus, value)
    end

    def typeTruthValue do
      %{
        true: 1,
        false: 2
      }
    end
    def typeTruthValue(value) when is_atom(value) do
      typeTruthValue[value]
    end
    def typeTruthValue(value) when is_integer(value) do
      Util.get_key_by_value(typeTruthValue, value)
    end

    def ccCopyProtocol do
      ccCopyProtocol(%CcCopyEntry{})
    end
    def ccCopyProtocol(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.2",
        :integer, ccCopyEntry.ccCopyProtocol)
    end
    def ccCopyProtocol(ccCopyEntry, value) do
      typeConfigCopyProtocol
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyProtocol: v} end).()
    end

    def ccCopySourceFileType do
      ccCopySourceFileType(%CcCopyEntry{})
    end
    def ccCopySourceFileType(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.3",
        :integer, ccCopyEntry.ccCopySourceFileType)
    end
    def ccCopySourceFileType(ccCopyEntry, value) do
      typeConfigFileType
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopySourceFileType: v} end).()
    end

    def ccCopyDestFileType do
      ccCopyDestFileType(%CcCopyEntry{})
    end
    def ccCopyDestFileType(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.4",
        :integer, ccCopyEntry.ccCopyDestFileType)
    end
    def ccCopyDestFileType(ccCopyEntry, value) do
      typeConfigFileType
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyDestFileType: v} end).()
    end

    def ccCopyFileName do
      ccCopyFileName(%CcCopyEntry{})
    end
    def ccCopyFileName(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.6",
        :octet_string, ccCopyEntry.ccCopyFileName)
    end
    def ccCopyFileName(ccCopyEntry, value) when is_binary(value) do
      %CcCopyEntry{ccCopyEntry|ccCopyFileName: value}
    end

    def ccCopyUserName do
      ccCopyUserName(%CcCopyEntry{})
    end
    def ccCopyUserName(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.7",
        :octet_string, ccCopyEntry.ccCopyUserName)
    end
    def ccCopyUserName(ccCopyEntry, value) do
      %CcCopyEntry{ccCopyEntry|ccCopyUserName: value}
    end

    def ccCopyUserPassword do
      ccCopyUserPassword(%CcCopyEntry{})
    end
    def ccCopyUserPassword(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.8",
        :octet_string, ccCopyEntry.ccCopyUserPassword)
    end
    def ccCopyUserPassword(ccCopyEntry, value) do
      %CcCopyEntry{ccCopyEntry|ccCopyUserPassword: value}
    end

    def ccCopyNotificationOnCompletion do
      ccCopyNotificationOnCompletion(%CcCopyEntry{})
    end
    def ccCopyNotificationOnCompletion(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.9",
        :integer, ccCopyEntry.ccCopyNotificationOnCompletion)
    end
    def ccCopyNotificationOnCompletion(ccCopyEntry, value) when value in 1..2 do
      typeTruthValue
        |> Map.fetch!(value)
        |> (fn v ->
          %CcCopyEntry{ccCopyEntry|ccCopyNotificationOnCompletion: v}
        end).()
    end

    def ccCopyState do
      ccCopyState(%CcCopyEntry{})
    end
    def ccCopyState(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.10",
        :integer, ccCopyEntry.ccCopyState)
    end
    def ccCopyState(ccCopyEntry, value) do
      typeConfigCopyState
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyState: v} end).()
    end

    def ccCopyTimeStarted do
      ccCopyTimeStarted(%CcCopyEntry{})
    end
    def ccCopyTimeStarted(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.11",
        :octet_string, ccCopyEntry.ccCopyTimeStarted)
    end
    def ccCopyTimeStarted(ccCopyEntry, value) do
      %CcCopyEntry{ccCopyEntry|ccCopyTimeStarted: value}
    end

    def ccCopyTimeCompleted do
      ccCopyTimeCompleted(%CcCopyEntry{})
    end
    def ccCopyTimeCompleted(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.12",
        :octet_string, ccCopyEntry.ccCopyTimeCompleted)
    end
    def ccCopyTimeCompleted(ccCopyEntry, value) do
      %CcCopyEntry{ccCopyEntry|ccCopyTimeCompleted: value}
    end

    def ccCopyFailCause do
      ccCopyFailCause(%CcCopyEntry{})
    end
    def ccCopyFailCause(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.13",
        :integer, ccCopyEntry.ccCopyFailCause)
    end
    def ccCopyFailCause(ccCopyEntry, value) do
      typeConfigCopyFailCause
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyFailCause: v} end).()
    end

    def ccCopyEntryRowStatus do
      ccCopyEntryRowStatus(%CcCopyEntry{})
    end
    def ccCopyEntryRowStatus(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.14",
        :integer, ccCopyEntry.ccCopyEntryRowStatus)
    end
    def ccCopyEntryRowStatus(ccCopyEntry, value) do
      typeRowStatus
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyEntryRowStatus: v} end).()
    end

    def ccCopyServerAddressType do
      ccCopyServerAddressType(%CcCopyEntry{})
    end
    def ccCopyServerAddressType(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.15",
        :integer, ccCopyEntry.ccCopyServerAddressType)
    end
    def ccCopyServerAddressType(ccCopyEntry, value) do
      typeInetAddressType
        |> Map.fetch!(value)
        |> (fn v -> %CcCopyEntry{ccCopyEntry|ccCopyServerAddressType: v} end).()
    end

    def ccCopyServerAddressRev1 do
      ccCopyServerAddressRev1(%CcCopyEntry{})
    end
    def ccCopyServerAddressRev1(ccCopyEntry) do
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.16",
        :octet_string, ccCopyEntry.ccCopyServerAddressRev1)
    end
    def ccCopyServerAddressRev1(ccCopyEntry, value) do
      %CcCopyEntry{ccCopyEntry|ccCopyServerAddressRev1: value}
    end
  end

  @spec cc_copy_entry(atom, atom, atom, String.t, atom, String.t) :: CcCopyEntry.t
  def cc_copy_entry(proto, src_file_type, dst_file_type, filename, server_addr_type, server_addr) do
    %CcCopyEntry{}
      |> CcCopyEntry.ccCopyProtocol(proto)
      |> CcCopyEntry.ccCopySourceFileType(src_file_type)
      |> CcCopyEntry.ccCopyDestFileType(dst_file_type)
      |> CcCopyEntry.ccCopyFileName(filename)
      |> CcCopyEntry.ccCopyServerAddressType(server_addr_type)
      |> CcCopyEntry.ccCopyServerAddressRev1(server_addr)
      |> CcCopyEntry.ccCopyEntryRowStatus(:create_and_go)
  end

  def get_copy_state(row, agent, credential) do
    result = CcCopyEntry.ccCopyState
      |> SNMP.Object.index(row)
      |> SNMP.get(agent, credential)

    case result do
      [ok: copy_state_obj] ->
        copy_state_obj
          |> SNMP.Object.value
          |> String.to_integer
      [error: _] ->
        nil
    end
  end

  def get_copy_fail_cause(row, agent, credential) do
    result = CcCopyEntry.ccCopyFailCause
      |> SNMP.Object.index(row)
      |> SNMP.get(agent, credential)

    case result do
      [ok: copy_fail_cause_obj] ->
        copy_fail_cause_obj
          |> SNMP.Object.value
          |> String.to_integer
      [error: _] ->
        nil
    end
  end

  def await_copy_result(row, agent, credential) do
    case get_copy_state(row, agent, credential) do
      3 ->
        :ok
      4 ->
        fail_cause = get_copy_fail_cause(row, agent, credential)
          |> SNMP.Cisco.CcCopyEntry.typeConfigCopyFailCause

        {:error, fail_cause}
      _ ->
        :timer.sleep 500 
        await_copy_result(row, agent, credential)
    end 
  end

  def destroy_copy_entry_row(row, agent, credential) do
    [{:ok, _}] = CcCopyEntry.ccCopyEntryRowStatus
      |> SNMP.Object.index(row)
      |> SNMP.Object.value(6)
      |> SNMP.set(agent, credential)
  end

  defp create_copy_entry_row(copy_entry, agent, credential) do
    row = 1
    [
      CcCopyEntry.ccCopyProtocol(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopySourceFileType(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopyDestFileType(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopyFileName(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopyServerAddressType(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopyServerAddressRev1(copy_entry) |> SNMP.Object.index(row),
      CcCopyEntry.ccCopyEntryRowStatus(copy_entry) |> SNMP.Object.index(row)
    ] |> SNMP.set(agent, credential)

    row
  end

  def copy_tftp_run(tftp_server, file, agent, credential) do
    row = cc_copy_entry(:tftp,
        :network_file, :running_config, file,
        :ipv4, tftp_server
    ) |> create_copy_entry_row(agent, credential)
    
    :ok = await_copy_result(row, agent, credential)
    destroy_copy_entry_row(row, agent, credential)
  end
end

