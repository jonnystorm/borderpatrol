# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule ACE do
  defstruct action: nil, ip_proto: nil, values: [], masks: []
  @type t :: %ACE{action: :permit|:deny, ip_proto: atom, values: list, masks: list}

  def new(action, ip_protocol, values, masks) do
    %ACE{action: action, ip_proto: ip_protocol, values: values, masks: masks}
  end

  def action(ace), do: ace.action
  def ip_protocol(ace), do: ace.ip_proto
  def values(ace), do: ace.values
  def masks(ace), do: ace.masks

  def icmp(action, src, dst, type, code) do
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

    ACE.new(action, :icmp,
      [PCI.IP.new(src, dst), PCI.ICMP.new(type, code)],
      [PCI.IP.new(src_mask, dst_mask), PCI.ICMP.new(type_mask, code_mask)]
    )
  end

  def tcp(action, src, src_port, dst, dst_port) do
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

    ACE.new(action, :tcp,
      [PCI.IP.new(src, dst), PCI.TCP.new(src_port, dst_port)],
      [PCI.IP.new(src_mask, dst_mask), PCI.TCP.new(spt_mask, dpt_mask)]
    )
  end

  def udp(action, src, src_port, dst, dst_port) do
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
      dst_mask = <<0xffff::16>>
    end

    src_port = <<src_port::16>>
    dst_port = <<dst_port::16>>

    ACE.new(action, :udp,
      [PCI.IP.new(src, dst), PCI.UDP.new(src_port, dst_port)],
      [PCI.IP.new(src_mask, dst_mask), PCI.UDP.new(spt_mask, dpt_mask)]
    )
  end
end

defmodule ACL do
  defstruct version: nil, name: nil, aces: []
  @type t :: %ACL{version: 4 | 6, name: String.t, aces: list}

  @spec new(4 | 6, String.t) :: ACL.t
  def new(4, name) when is_binary(name), do: %ACL{version: 4, name: name}
  def new(6, name) when is_binary(name), do: %ACL{version: 6, name: name}
  def new(4, name, aces) when is_binary(name) and is_list(aces) do
    %ACL{version: 4, name: name, aces: aces}
  end
  def new(6, name, aces) when is_binary(name) and is_list(aces) do
    %ACL{version: 6, name: name, aces: aces}
  end

  def aces(acl), do: acl.aces
  def name(acl), do: acl.name
  def version(acl), do: acl.version

  @spec append(ACL.t, ACE.t) :: ACL.t
  def append(acl, ace) do
    new(version(acl), name(acl), aces(acl) ++ [ace])
  end

  defp append_icmp_ace(acl, action, src, dst, type, code) do
    append(acl, ACE.icmp(action, src, dst, type, code))
  end

  defp append_tcp_ace(acl, action, src, src_port, dst, dst_port) do
    append(acl, ACE.tcp(action, src, src_port, dst, dst_port))
  end

  defp append_udp_ace(acl, action, src, src_port, dst, dst_port) do
    append(acl, ACE.udp(action, src, src_port, dst, dst_port))
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
    if ACL.version(acl) == 6 do
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
