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
      ccCopyServerAddressType: nil,
      ccCopyServerAddressRev1: nil,
      ccCopyEntryRowStatus: nil,
      ccCopyState: nil,
      ccCopyFailCause: nil
    ]
    @type t :: %CcCopyEntry{
      ccCopyProtocol: 1..5,
      ccCopySourceFileType: 1..6,
      ccCopyDestFileType: 1..6,
      ccCopyFileName: String.t,
      ccCopyServerAddressType: 0..4 | 16,
      ccCopyServerAddressRev1: String.t,
      ccCopyEntryRowStatus: 1..6,
      ccCopyState: 1..4,
      ccCopyFailCause: 1..9
    }

    def protocol(ccCopyEntry), do: ccCopyEntry.ccCopyProtocol
    def source_file_type(ccCopyEntry), do: ccCopyEntry.ccCopySourceFileType
    def dest_file_type(ccCopyEntry), do: ccCopyEntry.ccCopyDestFileType
    def filename(ccCopyEntry), do: ccCopyEntry.ccCopyFileName
    def server_address_type(ccCopyEntry), do: ccCopyEntry.ccCopyServerAddressType
    def server_address(ccCopyEntry), do: ccCopyEntry.ccCopyServerAddressRev1
    def entry_row_status(ccCopyEntry), do: ccCopyEntry.ccCopyEntryRowStatus
    def copy_state(ccCopyEntry), do: ccCopyEntry.ccCopyState
    def copy_fail_cause(ccCopyEntry), do: ccCopyEntry.ccCopyFailCause

    @spec config_copy_proto_to_number(atom) :: 1..5
    def config_copy_proto_to_number(proto) do
      %{
        tftp: 1,
        ftp: 2,
        rcp: 3,
        scp: 4,
        sftp: 5
      } |> Map.fetch!(proto)
    end

    @spec config_file_type_to_number(atom) :: 1..6
    def config_file_type_to_number(type) do
      %{
        network_file: 1,
        ios_file: 2,
        startup_config: 3,
        running_config: 4,
        terminal: 5,
        fabric_startup_config: 6
      } |> Map.fetch!(type)
    end

    @spec row_status_to_number(atom) :: 1..6
    def row_status_to_number(row_status) do
      %{
        active: 1,
        not_in_service: 2,
        not_ready: 3,
        create_and_go: 4,
        create_and_wait: 5,
        destroy: 6
      } |> Map.fetch!(row_status)
    end

    @spec number_to_row_status(1..6) :: atom
    def number_to_row_status(number) do
      %{
        1 => :active,
        2 => :not_in_service,
        3 => :not_ready,
        4 => :create_and_go,
        5 => :create_and_wait,
        6 => :destroy
      } |> Map.fetch!(number)
    end

    @spec inet_addr_type_to_number(atom) :: 0..4 | 16
    def inet_addr_type_to_number(type) do
      %{
        unknown: 0,
        ipv4: 1,
        ipv6: 2,
        ipv4z: 3,
        ipv6z: 4,
        dns: 16
      } |> Map.fetch!(type)
    end

    @spec copy_state_to_number(atom) :: 1..4
    def copy_state_to_number(state) do
      %{
        waiting: 1,
        running: 2,
        successful: 3,
        failed: 4
      } |> Map.fetch!(state)
    end

    @spec number_to_copy_state(1..4) :: atom
    def number_to_copy_state(number) do
      %{
        1 => :waiting,
        2 => :running,
        3 => :successful,
        4 => :failed
      } |> Map.fetch!(number)
    end

    @spec copy_fail_cause_to_number(atom) :: 1..9
    def copy_fail_cause_to_number(cause) do
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
      } |> Map.fetch!(cause)
    end

    @spec number_to_copy_fail_cause(1..9) :: atom
    def number_to_copy_fail_cause(number) do
      %{
        1 => :unknown,
        2 => :bad_file_name,
        3 => :timeout,
        4 => :no_mem,
        5 => :no_config,
        6 => :unsupported_protocol,
        7 => :some_config_apply_failed,
        8 => :system_not_ready,
        9 => :request_aborted
      } |> Map.fetch!(number)
    end
  end

  @spec cc_copy_entry(atom, atom, atom, String.t, atom, String.t) :: CcCopyEntry.t
  def cc_copy_entry(proto, src_file_type, dst_file_type, filename, server_addr_type, server_addr) do
    %CcCopyEntry{
      ccCopyProtocol: CcCopyEntry.config_copy_proto_to_number(proto),
      ccCopySourceFileType: CcCopyEntry.config_file_type_to_number(src_file_type),
      ccCopyDestFileType: CcCopyEntry.config_file_type_to_number(dst_file_type),
      ccCopyFileName: filename,
      ccCopyServerAddressType: CcCopyEntry.inet_addr_type_to_number(server_addr_type),
      ccCopyServerAddressRev1: server_addr,
      ccCopyEntryRowStatus: CcCopyEntry.row_status_to_number(:create_and_go),
      ccCopyState: CcCopyEntry.copy_state_to_number(:waiting),
      ccCopyFailCause: CcCopyEntry.copy_fail_cause_to_number(:unknown)
    }
  end

  @spec cc_copy_entry_to_snmp_objects(CcCopyEntry.t, pos_integer) :: [SNMP.Object.t]
  def cc_copy_entry_to_snmp_objects(ccCopyEntry, row) do
    [
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.2.#{row}",
        :integer, CcCopyEntry.protocol(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.3.#{row}",
        :integer, CcCopyEntry.source_file_type(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.4.#{row}",
        :integer, CcCopyEntry.dest_file_type(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.6.#{row}",
        :octet_string, CcCopyEntry.filename(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.15.#{row}",
        :integer, CcCopyEntry.server_address_type(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.16.#{row}",
        :octet_string, CcCopyEntry.server_address(ccCopyEntry)),
      SNMP.object("1.3.6.1.4.1.9.9.96.1.1.1.1.14.#{row}",
        :integer, CcCopyEntry.entry_row_status(ccCopyEntry))
    ]
  end
end

