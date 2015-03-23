# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule ACE do
  defstruct ip_version: nil, action: nil, ip_proto: nil, values: [], masks: []
  @type t :: %ACE{
    ip_version: 4 | 6,
    action: :permit | :deny,
    ip_proto: atom,
    values: list,
    masks: list
  }

  def new(ip_version, action, ip_protocol, values, masks) do
    %ACE{
      ip_version: ip_version,
      action: action,
      ip_proto: ip_protocol,
      values: values,
      masks: masks
    }
  end

  def ip_version(ace) do
    ace.ip_version
  end

  def action(ace) do
    ace.action
  end
  def action(ace, new_action) when new_action in [:permit, :deny] do
    %ACE{ace|action: new_action}
  end

  def ip_protocol(ace) do
    ace.ip_proto
  end

  def values(ace) do
    ace.values
  end
  
  def masks(ace) do
    ace.masks
  end

  def icmp(ip_version, action, src, dst, type, code) do
    {src, src_mask} = IP.prefix_to_binary(src)
    {dst, dst_mask} = IP.prefix_to_binary(dst)

    type_mask = <<0xff>>
    code_mask = <<0xff>>

    if type == :any do
      type = 0
      type_mask = <<0>>
    end

    if code == :any do
      code = 0
      code_mask = <<0>>
    end

    type = <<type>>
    code = <<code>>

    ACE.new(ip_version, action, :icmp,
      [PCI.IP.new(src, dst), PCI.ICMP.new(type, code)],
      [PCI.IP.new(src_mask, dst_mask), PCI.ICMP.new(type_mask, code_mask)]
    )
  end

  def tcp(ip_version, action, src, src_port, dst, dst_port) do
    {src, src_mask} = IP.prefix_to_binary(src)
    {dst, dst_mask} = IP.prefix_to_binary(dst)
    
    if src_port == :any do
      src_port = 0
      spt_mask = <<0::16>>
    else
      spt_mask = <<0xffff::16>>
    end

    if dst_port == :any do
      dst_port = 0
      dpt_mask = <<0::16>>
    else
      dpt_mask = <<0xffff::16>>
    end

    src_port = <<src_port::16>>
    dst_port = <<dst_port::16>>

    ACE.new(ip_version, action, :tcp,
      [PCI.IP.new(src, dst), PCI.TCP.new(src_port, dst_port)],
      [PCI.IP.new(src_mask, dst_mask), PCI.TCP.new(spt_mask, dpt_mask)]
    )
  end

  def udp(ip_version, action, src, src_port, dst, dst_port) do
    {src, src_mask} = IP.prefix_to_binary(src)
    {dst, dst_mask} = IP.prefix_to_binary(dst)

    if src_port == :any do
      src_port = 0
      spt_mask = <<0::16>>
    else
      spt_mask = <<0xffff::16>>
    end

    if dst_port == :any do
      dst_port = 0
      dpt_mask = <<0::16>>
    else
      dpt_mask = <<0xffff::16>>
    end

    src_port = <<src_port::16>>
    dst_port = <<dst_port::16>>

    ACE.new(ip_version, action, :udp,
      [PCI.IP.new(src, dst), PCI.UDP.new(src_port, dst_port)],
      [PCI.IP.new(src_mask, dst_mask), PCI.UDP.new(spt_mask, dpt_mask)]
    )
  end

  @spec reflect(ACE.t) :: ACE.t
  def reflect(ace) do
    [ip_value, ip_proto_value] = values(ace)
    [ip_mask, ip_proto_mask] = masks(ace)

    ACE.new(ip_version(ace), action(ace), ip_protocol(ace),
      [PCIProto.reflect(ip_value), PCIProto.reflect(ip_proto_value)],
      [PCIProto.reflect(ip_mask), PCIProto.reflect(ip_proto_mask)]
    )
  end
end

defmodule ACL do
  defmacro __using__(_opts) do
    quote do
      import ACL
    end
  end

  defmacro host(host) do
    quote do
      unquote(host) <> "/32"
    end
  end

  defmacro eq(port) do
    quote do
      [eq: unquote(port)]
    end
  end

  defstruct ip_version: nil, name: nil, aces: []
  @type t :: %ACL{ip_version: 4 | 6, name: String.t, aces: list}

  @spec new(4 | 6) :: ACL.t
  @spec new(4 | 6, String.t) :: ACL.t
  @spec new(4 | 6, String.t, [ACE.t]) :: ACL.t
  def new(4) do
    %ACL{ip_version: 4, name: ""}
  end
  def new(6) do
    %ACL{ip_version: 6, name: ""}
  end
  def new(4, name) when is_binary(name) do
    %ACL{ip_version: 4, name: name}
  end
  def new(6, name) when is_binary(name) do
    %ACL{ip_version: 6, name: name}
  end
  def new(4, name, aces) when is_binary(name) and is_list(aces) do
    %ACL{ip_version: 4, name: name, aces: aces}
  end
  def new(6, name, aces) when is_binary(name) and is_list(aces) do
    %ACL{ip_version: 6, name: name, aces: aces}
  end

  def aces(acl) do
    acl.aces
  end
  def aces(acl, aces) when is_list(aces) do
    %ACL{acl|aces: aces}
  end

  def name(acl) do
    acl.name
  end
  def name(acl, new_name) when is_binary(new_name) do
    %ACL{acl|name: new_name}
  end

  def ip_version(acl) do
    acl.ip_version
  end

  @spec append(ACL.t, ACE.t) :: ACL.t
  def append(acl, ace) do
    case ip_version(acl) / ACE.ip_version(ace) do
      1.0 ->
        acl |> aces(aces(acl) ++ [ace])
      _ ->
        raise ArgumentError, message: "ACL and ACE must have same IP version"
    end
  end

  @spec concat(ACL.t, ACL.t) :: ACL.t
  def concat(acl1, acl2) do
    case ip_version(acl1) / ip_version(acl2) do
      1.0 ->
        acl1 |> aces(aces(acl1) ++ aces(acl2))
      _ ->
        raise ArgumentError, message: "ACLs must have the same IP version"
    end
  end

  @spec interleave(ACL.t, ACL.t) :: ACL.t
  def interleave(acl1, acl2) do
    case ip_version(acl1) / ip_version(acl2) do
      1.0 ->
        interleaved_aces = aces(acl1) |> Util.flat_zip(aces acl2)
        remaining = [aces(acl1), aces(acl2)]
          |> Enum.max_by(fn l -> length l end)
          |> Enum.drop(div length(interleaved_aces), 2)
        acl1 |> aces(interleaved_aces ++ remaining)
      _ ->
        raise ArgumentError, message: "ACLs must have the same IP version"
    end
  end

  @spec reflect(ACL.t) :: ACL.t
  def reflect(acl) do
    reflected_aces = aces(acl) |> Enum.map(&(ACE.reflect &1))

    acl |> aces(reflected_aces)
  end

  defp append_icmp_ace(acl, action, src, dst, type, code) do
    append(acl, ACE.icmp(ip_version(acl), action, src, dst, type, code))
  end

  defp append_tcp_ace(acl, action, src, src_port, dst, dst_port) do
    append(acl, ACE.tcp(ip_version(acl), action, src, src_port, dst, dst_port))
  end

  defp append_udp_ace(acl, action, src, src_port, dst, dst_port) do
    append(acl, ACE.udp(ip_version(acl), action, src, src_port, dst, dst_port))
  end

  def permit(acl, :icmp, source, destination) do
    append_icmp_ace(acl, :permit, source, destination, :any, :any)
  end
  def permit(acl, :tcp, source, destination) do
    append_tcp_ace(acl, :tcp, source, :any, destination, :any)
  end
  def permit(acl, :udp, source, destination) do
    append_udp_ace(acl, :udp, source, :any, destination, :any)
  end

  def permit(acl, :tcp, source, [eq: source_port], destination) do
    append_tcp_ace(acl, :permit, source, source_port, destination, :any)
  end
  def permit(acl, :tcp, source, destination, [eq: destination_port]) do
    append_tcp_ace(acl, :permit, source, :any, destination, destination_port)
  end
  def permit(acl, :udp, source, [eq: source_port], destination) do
    append_udp_ace(acl, :permit, source, source_port, destination, :any)
  end
  def permit(acl, :udp, source, destination, [eq: destination_port]) do
    append_udp_ace(acl, :permit, source, :any, destination, destination_port)
  end

  def permit(acl, :icmp, source, destination, type, code) do
    append_icmp_ace(acl, :permit, source, destination, type, code)
  end
  def permit(acl, :tcp, source, source_port, destination, destination_port) do
    append_tcp_ace(acl, :permit, source, source_port, destination, destination_port)
  end
  def permit(acl, :udp, source, source_port, destination, destination_port) do
    append_udp_ace(acl, :permit, source, source_port, destination, destination_port)
  end

  def deny(acl, :icmp, source, destination) do
    append_icmp_ace(acl, :deny, source, destination, :any, :any)
  end
  def deny(acl, :tcp, source, destination) do
    append_tcp_ace(acl, :deny, source, :any, destination, :any)
  end
  def deny(acl, :udp, source, destination) do
    append_udp_ace(acl, :deny, source, :any, destination, :any)
  end

  def deny(acl, :tcp, source, [eq: source_port], destination) do
    append_tcp_ace(acl, :deny, source, source_port, destination, :any)
  end
  def deny(acl, :tcp, source, destination, [eq: destination_port]) do
    append_tcp_ace(acl, :deny, source, :any, destination, destination_port)
  end
  def deny(acl, :udp, source, [eq: source_port], destination) do
    append_udp_ace(acl, :deny, source, source_port, destination, :any)
  end
  def deny(acl, :udp, source, destination, [eq: destination_port]) do
    append_udp_ace(acl, :deny, source, :any, destination, destination_port)
  end

  def deny(acl, :icmp, source, destination, type, code) do
    append_icmp_ace(acl, :deny, source, destination, type, code)
  end
  def deny(acl, :tcp, source, source_port, destination, destination_port) do
    append_tcp_ace(acl, :deny, source, source_port, destination, destination_port)
  end
  def deny(acl, :udp, source, source_port, destination, destination_port) do
    append_udp_ace(acl, :deny, source, source_port, destination, destination_port)
  end
end

defimpl String.Chars, for: ACE do
  import Kernel, except: [to_string: 1]

  @doc """
  Fix this awful mess.
  """
  def to_string(ace) do
    action = ACE.action(ace)
    [ip_values, ip_masks, l4_values, l4_masks] = ACE.values(ace)
      |> Enum.zip(ACE.masks ace)
      |> Enum.map(&(Tuple.to_list &1))
      |> List.flatten
    src = ip_values
      |> PCI.IP.source
      |> IP.IPv4Addr.new
    dst = ip_values
      |> PCI.IP.destination
      |> IP.IPv4Addr.new
    smask = ip_masks
      |> PCI.IP.source
      |> (fn s -> IP.invert_mask s end).()
      |> IP.IPv4Addr.new
    dmask = ip_masks
      |> PCI.IP.destination
      |> (fn s -> IP.invert_mask s end).()
      |> IP.IPv4Addr.new

    case ACE.ip_protocol(ace) do
      :icmp ->
        type = l4_values
          |> PCI.ICMP.type
          |> PCI.bits_to_integer
        code = l4_values
          |> PCI.ICMP.code
          |> PCI.bits_to_integer
        tmask = l4_masks
          |> PCI.ICMP.type
          |> PCI.bits_to_integer
        cmask = l4_masks
          |> PCI.ICMP.code
          |> PCI.bits_to_integer
        
        case tmask do
          0x0 ->
            "#{action} icmp #{src} #{smask} #{dst} #{dmask}"
          0xff ->
            case cmask do
              0x0 ->
                "#{action} icmp #{src} #{smask} #{dst} #{dmask} #{type}"
              0xff ->
                "#{action} icmp #{src} #{smask} #{dst} #{dmask} #{type} #{code}"
            end
        end
      :tcp ->
        spt = l4_values
          |> PCI.TCP.source
          |> PCI.bits_to_integer
        dpt = l4_values
          |> PCI.TCP.destination
          |> PCI.bits_to_integer
        sptmask = l4_masks
          |> PCI.TCP.source
          |> PCI.bits_to_integer
        dptmask = l4_masks
          |> PCI.TCP.destination
          |> PCI.bits_to_integer

        case sptmask do
          0x0 ->
            case dptmask do
              0x0 ->
                "#{action} tcp #{src} #{smask} #{dst} #{dmask}"
              0xffff ->
                "#{action} tcp #{src} #{smask} #{dst} #{dmask} eq #{dpt}"
            end
          0xffff ->
            case dptmask do
              0x0 ->
                "#{action} tcp #{src} #{smask} eq #{spt} #{dst} #{dmask}"
              0xffff ->
                "#{action} tcp #{src} #{smask} eq #{spt} #{dst} #{dmask} eq #{dpt}"
            end
        end
      :udp ->
        spt = l4_values
          |> PCI.UDP.source
          |> PCI.bits_to_integer
        dpt = l4_values
          |> PCI.UDP.destination
          |> PCI.bits_to_integer
        sptmask = l4_masks
          |> PCI.UDP.source
          |> PCI.bits_to_integer
        dptmask = l4_masks
          |> PCI.UDP.destination
          |> PCI.bits_to_integer

        case sptmask do
          0x0 ->
            case dptmask do
              0x0 ->
                "#{action} udp #{src} #{smask} #{dst} #{dmask}"
              0xffff ->
                "#{action} udp #{src} #{smask} #{dst} #{dmask} eq #{dpt}"
            end
          0xffff ->
            case dptmask do
              0x0 ->
                "#{action} udp #{src} #{smask} eq #{spt} #{dst} #{dmask}"
              0xffff ->
                "#{action} udp #{src} #{smask} eq #{spt} #{dst} #{dmask} eq #{dpt}"
            end
        end
      _ ->
        ""
    end
  end
end

defimpl String.Chars, for: ACL do
  import Kernel, except: [to_string: 1]

  def to_string(acl) do
    if ACL.ip_version(acl) == 6 do
      base_str = "ipv6"
    else
      base_str = "ip"
    end

    acl_name = acl
      |> ACL.name
      |> String.downcase
      |> String.replace(" ", "_")

    ([base_str <> " access-list extended " <> acl_name, "\n"]
      ++ (for ace <- ACL.aces(acl), do: "  #{ace}\n"))
      |> Enum.join
  end
end
