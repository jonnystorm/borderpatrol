# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule SNMP do
  defmodule Agent do
    defstruct host: nil, proto: nil, port: nil
    @type t :: %Agent{host: String.t, proto: :udp | :tcp, port: 0..65535}

    def host(agent), do: agent.host
    def protocol(agent), do: agent.proto
    def port(agent), do: agent.port
  end

  defmodule Object do
    defstruct oid: nil, type: nil, value: nil
    @type t :: %Object{
      oid: [non_neg_integer],
      type: 0 | 1..6 | 9..10,
      value: String.t | number
    }
    
    def oid(object), do: object.oid
    def oid(object, new_value), do: %Object{object|oid: new_value}
    def type(object), do: object.type
    def type(object, new_type), do: %Object{object|type: new_type}
    def value(object), do: object.value
    def value(object, new_value), do: %Object{object|value: new_value}

    @spec oid_list_to_string([non_neg_integer]) :: String.t
    def oid_list_to_string(oid_list) do
      oid_list |> Enum.join "."
    end

    @spec oid_string_to_list(String.t) :: [non_neg_integer]
    def oid_string_to_list(oid_string) do
      oid_string
        |> String.strip(?.)
        |> :binary.split(".", [:global])
        |> Enum.map(&(String.to_integer &1))
    end

    @spec asn1_tag_to_type(0 | 1..6 | 9..10) :: pos_integer
    def asn1_tag_to_type(type) do
      %{
        0 => "=",
        1 => "i",
        2 => "i",
        3 => "s",
        4 => "s",
        5 => "=",
        6 => "o",
        9 => "d",
        10 => "i"
      } |> Map.fetch!(type)
    end
    @spec type_to_asn1_tag(atom) :: 0 | 1..6 | 9..10
    def type_to_asn1_tag(type) do
      %{
        any: 0,
        boolean: 1,
        integer: 2,
        bit_string: 3,
        octet_string: 4, string: 4,
        null: 5,
        object_identifier: 6,
        real: 9,
        enumerated: 10
      } |> Map.fetch!(type)
    end

    @spec index(Object.t, pos_integer) :: Object.t
    def index(object, index) when is_integer(index) do
      Object.oid(object, Object.oid(object) ++ [index])
    end
  end

  @spec agent(String.t, :tcp | :udp, 0..65535) :: Agent.t
  def agent(host, protocol, port)
      when protocol in [:tcp, :udp] and port in 0..65535 do
    %Agent{host: host, proto: protocol, port: port}
  end

  @spec object(String.t, atom, String.t | number) :: Object.t
  def object(oid, type, value) do
    %Object{
      oid: Object.oid_string_to_list(oid),
      type: Object.type_to_asn1_tag(type),
      value: value
    }
  end

  @spec credential(:v2c, String.t) :: Keyword.t
  @spec credential(:v3, :no_auth_no_priv, String.t) :: Keyword.t
  @spec credential(:v3, :auth_no_priv, String.t, :md5 | :sha, String.t) :: Keyword.t
  @spec credential(:v3, :auth_priv, String.t, :md5 | :sha, String.t, :des | :aes, String.t) :: Keyword.t
  def credential(:v2c, community) do
    [
      version: "2c",
      community: community
    ]
  end
  def credential(:v3, :no_auth_no_priv, sec_name) do
    [
      version: "3",
      sec_level: "noAuthNoPriv",
      sec_name: sec_name
    ]
  end
  def credential(:v3, :auth_no_priv, sec_name, auth_proto, auth_pass)
      when auth_proto in [:md5, :sha] do
    [
      version: "3",
      sec_level: "authNoPriv",
      sec_name: sec_name,
      auth_proto: to_string(auth_proto),
      auth_pass: auth_pass
    ]
  end
  def credential(:v3, :auth_priv, sec_name, auth_proto, auth_pass, priv_proto, priv_pass)
      when auth_proto in [:md5, :sha] and priv_proto in [:des, :aes] do
    [
      version: "3",
      sec_level: "authPriv",
      sec_name: sec_name,
      auth_proto: to_string(auth_proto),
      auth_pass: auth_pass,
      priv_proto: to_string(priv_proto),
      priv_pass: priv_pass
    ]
  end

  defp _credential_to_snmpcmd_args([], acc) do
    Enum.join(acc, " ")
  end
  defp _credential_to_snmpcmd_args([{:version, version}|tail], acc) do
    _credential_to_snmpcmd_args(tail, ["-v#{version}"|acc])
  end
  defp _credential_to_snmpcmd_args([{:community, community}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-c #{community}"])
  end
  defp _credential_to_snmpcmd_args([{:sec_level, sec_level}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-l#{sec_level}"])
  end
  defp _credential_to_snmpcmd_args([{:sec_name, sec_name}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-u #{sec_name}"])
  end
  defp _credential_to_snmpcmd_args([{:auth_proto, auth_proto}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-a #{auth_proto}"])
  end
  defp _credential_to_snmpcmd_args([{:auth_pass, auth_pass}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-A #{auth_pass}"])
  end
  defp _credential_to_snmpcmd_args([{:priv_proto, priv_proto}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-x #{priv_proto}"])
  end
  defp _credential_to_snmpcmd_args([{:priv_pass, priv_pass}|tail], acc) do
    _credential_to_snmpcmd_args(tail, acc ++ ["-X #{priv_pass}"])
  end
  def credential_to_snmpcmd_args(credential) do
    _credential_to_snmpcmd_args(credential, [])
  end

  def gen_snmpcmd(:get, snmp_objects, agent, credential)
      when is_list(snmp_objects) do
    [
      "snmpget -On",
      credential_to_snmpcmd_args(credential),
      to_string(agent)|
      (for o <- snmp_objects, do: o |> Object.oid |> Object.oid_list_to_string)
    ] |> Enum.join(" ")
  end
  def gen_snmpcmd(:set, snmp_objects, agent, credential)
      when is_list(snmp_objects) do
    [
      "snmpset -On",
      credential_to_snmpcmd_args(credential),
      to_string(agent)|
      (for o <- snmp_objects, do: to_string o)
    ] |> Enum.join(" ")
  end

  defp parse_snmp_output(output) do
    output
      |> String.strip
      |> String.split("\n")
      |> Enum.map(fn o ->
        try do
          [oid, _, type_str, value] = String.split(o)
          type = type_str
            |> String.rstrip(?:)
            |> String.downcase
            |> String.to_atom

          {:ok, object(oid, type, value)}
        rescue
          _e in MatchError -> {:error, o}
        end
      end)
  end

  def get(snmp_objects, agent, credential) when is_list(snmp_objects) do
    gen_snmpcmd(:get, snmp_objects, agent, credential)
      |> Util.shell_cmd
      |> parse_snmp_output
  end
  def get(snmp_object, agent, credential) do
    get([snmp_object], agent, credential)
  end

  def set(snmp_objects, agent, credential) when is_list(snmp_objects) do
    gen_snmpcmd(:set, snmp_objects, agent, credential)
      |> Util.shell_cmd
      |> parse_snmp_output
  end
  def set(snmp_object, agent, credential) do
    set([snmp_object], agent, credential)
  end
end

defimpl String.Chars, for: SNMP.Agent do
  import Kernel, except: [to_string: 1]

  def to_string(agent) do
    transport_spec = agent
      |> SNMP.Agent.protocol
      |> Kernel.to_string
    transport_addr = SNMP.Agent.host(agent)
    transport_port = agent
      |> SNMP.Agent.port
      |> Kernel.to_string

    [transport_spec, transport_addr, transport_port]
      |> Enum.join ":"
  end
end

defimpl String.Chars, for: SNMP.Object do
  import Kernel, except: [to_string: 1]

  def to_string(object) do
    [
      object |> SNMP.Object.oid |> SNMP.Object.oid_list_to_string,
      object |> SNMP.Object.type |> SNMP.Object.asn1_tag_to_type,
      object |> SNMP.Object.value
    ] |> Enum.join " "
  end
end
