# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.Profile.Base do
  use ACL

  def client_ephemera_to_server(ip_protocol, client, server, port)
      when ip_protocol in [:tcp, :udp] and port in 0..65535 do
    ACL.new(4) |> permit(ip_protocol, client, server, eq(port))
  end

  def server_to_client_ephemera(ip_protocol, server, client, port)
      when ip_protocol in [:tcp, :udp] and port in 0..65535 do
    ACL.new(4) |> permit(ip_protocol, server, eq(port), client)
  end

  def icmp_client_to_server(client, server) do
    ACL.new(4) |> permit(:icmp, client, server)
  end

  def icmp_server_to_client(server, client) do
    icmp_client_to_server(server, client)
  end

  def icmp_echo_client_to_server(client, server) do
    ACL.new(4) |> permit(:icmp, client, server, 8, 0)
  end

  def icmp_echo_server_to_client(server, client) do
    ACL.new(4) |> permit(:icmp, server, client, 0, 0)
  end

  def icmp_type3_server_to_client(server, client) do
    ACL.new(4) |> permit(:icmp, server, client, 3, :any)
  end

  def dns_client_to_server(client, server) do
    client_ephemera_to_server(:udp, client, server, 53)
  end

  def dns_server_to_client(server, client) do
    server_to_client_ephemera(:udp, server, client, 53)
  end

  def http_client_to_server(client, server) do
    client_ephemera_to_server(:tcp, client, server, 80)
  end

  def http_server_to_client(server, client) do
    server_to_client_ephemera(:tcp, server, client, 80)
  end

  def https_client_to_server(client, server) do
    client_ephemera_to_server(:tcp, client, server, 443)
  end

  def https_server_to_client(server, client) do
    server_to_client_ephemera(:tcp, server, client, 443)
  end

  def ipsec_nat_t_client_to_server(client, server) do
    ACL.new(4) |> permit(:udp, client, eq(4500), server, eq(4500))
  end

  def ipsec_nat_t_server_to_client(server, client) do
    ipsec_nat_t_client_to_server(server, client)
  end

  def isakmp_client_to_server(client, server) do
    ACL.new(4) |> permit(:udp, client, eq(500), server, eq(500))
  end

  def isakmp_server_to_client(server, client) do
    isakmp_client_to_server(server, client)
  end

  def ntp_client_to_server(client, server) do
    client_ephemera_to_server(:udp, client, server, 123)
  end

  def ntp_server_to_client(server, client) do
    server_to_client_ephemera(:udp, server, client, 123)
  end

  def pdl_client_to_server(client, server) do
    client_ephemera_to_server(:tcp, client, server, 9100)
  end

  def pdl_server_to_client(server, client) do
    server_to_client_ephemera(:tcp, server, client, 9100)
  end

  def smtp_client_to_server(client, server) do
    client_ephemera_to_server(:tcp, client, server, 25)
  end

  def smtp_server_to_client(server, client) do
    server_to_client_ephemera(:tcp, server, client, 25)
  end

  def snmp_client_to_server(client, server) do
    client_ephemera_to_server(:udp, client, server, 161)
  end

  def snmp_server_to_client(server, client) do
    server_to_client_ephemera(:udp, server, client, 161)
  end

  def tcp_client_to_server(client, server) do
    ACL.new(4) |> permit(:tcp, client, server)
  end

  def tcp_server_to_client(server, client) do
    tcp_client_to_server(server, client)
  end

  def udp_client_to_server(client, server) do
    ACL.new(4) |> permit(:udp, client, server)
  end

  def udp_server_to_client(server, client) do
    udp_client_to_server(server, client)
  end
end
