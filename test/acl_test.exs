defmodule PCI.IPTest do
  use ExUnit.Case, async: true

  test "is_ipv6_string returns true for valid, unshortened IPv6" do
    assert PCI.IP.is_ipv6_string("fe80:0:0:0:0:0:0:1") == true
  end
  test "is_ipv6_string returns true for valid, shortened IPv6" do
    assert PCI.IP.is_ipv6_string("fe80::1") == true
  end
  test "is_ipv6_string returns false for empty string" do
    assert PCI.IP.is_ipv6_string("") == false
  end
  test "is_ipv6_string returns false for shortened IPv6 with bad characters" do
    assert PCI.IP.is_ipv6_string("fe8g::1") == false
  end
  test "is_ipv6_string returns false for unshortened IPv6 with bad characters" do
    assert PCI.IP.is_ipv6_string("fe8g:0:0:0:0:0:0:1") == false
  end
  test "is_ipv6_string returns false for unshortened IPv6 with too few words" do
    assert PCI.IP.is_ipv6_string("fe80:0:0:0:0:0:1") == false
  end
  test "is_ipv6_string returns false for incorrectly shortened IPv6" do
    assert PCI.IP.is_ipv6_string("fe80::2::") == false
  end
  test "is_ipv6_string returns false for truncated IPv6" do
    assert PCI.IP.is_ipv6_string("fe80:0:0:0:0:0:0:") == false
  end
  test "is_ipv6_string returns false for IPv6 with giant word" do
    assert PCI.IP.is_ipv6_string("afe80::") == false
  end

  test "expand_ipv6_string returns valid, unshortened IPv6 string unchanged" do
    assert PCI.IP.expand_ipv6_string("fe80:0:0:0:0:0:0:1") == "fe80:0:0:0:0:0:0:1"
  end
  test "expand_ipv6_string expands valid, shortened IPv6 string" do
    assert PCI.IP.expand_ipv6_string("fe80::1") == "fe80:0:0:0:0:0:0:1"
  end
  test "expand_ipv6_string expands a different valid, shortened IPv6 string" do
    assert PCI.IP.expand_ipv6_string("fe80:e800:11::2:0") == "fe80:e800:11:0:0:0:2:0"
  end
  test "expand_ipv6_string expands valid, shortened IPv6 string with last word as zero" do
    assert PCI.IP.expand_ipv6_string("fe80::") == "fe80:0:0:0:0:0:0:0"
  end
  test "expand_ipv6_string returns incorrectly shortened IPv6 string unchanged" do
    assert PCI.IP.expand_ipv6_string("fe80::2::") == "fe80::2::"
  end

  test "string_to_ipv6 correctly parses valid, shortened IPv6 string" do
    assert PCI.IP.string_to_ipv6("fe80::2:1") == {:ok, <<0xfe, 0x80, 2 :: 12 * 8, 0, 1>>}
  end
  test "string_to_ipv6 correctly parses valid, unshortened IPv6 string" do
    assert PCI.IP.string_to_ipv6("fe80:0:0:0:0:0:2:1") == {:ok, <<0xfe, 0x80, 2:: 12 * 8, 0, 1>>}
  end
  test "string_to_ipv6 fails for empty string" do
    assert PCI.IP.string_to_ipv6("") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for shortened IPv6 with bad characters" do
    assert PCI.IP.string_to_ipv6("fe8g::1") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for unshortened IPv6 with bad characters" do
    assert PCI.IP.string_to_ipv6("fe8g:0:0:0:0:0:0:1") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for unshortened IPv6 with too few words" do
    assert PCI.IP.string_to_ipv6("fe80:0:0:0:0:0:1") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for incorrectly shortened IPv6" do
    assert PCI.IP.string_to_ipv6("fe80::2::") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for truncated IPv6" do
    assert PCI.IP.string_to_ipv6("fe80:0:0:0:0:0:0:") == {:error, :badarg}
  end
  test "string_to_ipv6 fails for IPv6 with giant word" do
    assert PCI.IP.string_to_ipv6("afe80::") == {:error, :badarg}
  end

  test "is_ipv4_string returns true for valid IPv4" do
    assert PCI.IP.is_ipv4_string("192.0.2.1") == true
  end
  test "is_ipv4_string returns false for empty string" do
    assert PCI.IP.is_ipv4_string("") == false
  end
  test "is_ipv4_string returns false for IPv4 with bad characters" do
    assert PCI.IP.is_ipv4_string("192.0.2.a") == false
  end
  test "is_ipv4_string returns false for IPv4 with too few octets" do
    assert PCI.IP.is_ipv4_string("192.0.2") == false
  end
  test "is_ipv4_string returns false for truncated IPv4" do
    assert PCI.IP.is_ipv4_string("192.0.2.") == false
  end
  test "is_ipv4_string returns false for IPv4 with giant octet" do
    assert PCI.IP.is_ipv4_string("192.0.2.256") == false
  end

  test "string_to_ipv4 correctly parses valid IPv4" do
    assert PCI.IP.string_to_ipv4("192.0.2.0") == {:ok, <<192, 0, 2, 0>>}
  end
  test "string_to_ipv4 fails for empty string" do
    assert PCI.IP.string_to_ipv4("") == {:error, :badarg}
  end
  test "string_to_ipv4 fails for IPv4 with bad characters" do
    assert PCI.IP.string_to_ipv4("192.0.2.a") == {:error, :badarg}
  end
  test "string_to_ipv4 fails for IPv4 with too few octets" do
    assert PCI.IP.string_to_ipv4("192.0.2") == {:error, :badarg}
  end
  test "string_to_ipv4 fails for truncated IPv4" do
    assert PCI.IP.string_to_ipv4("192.0.2.") == {:error, :badarg}
  end
  test "string_to_ipv4 fails for IPv4 with giant octet" do
    assert PCI.IP.string_to_ipv4("192.0.2.256") == {:error, :badarg}
  end

  test "new returns correct IPv4 PCI for binary arguments" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using version integer" do
    assert PCI.IP.new(4, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using IP protocol integer" do
    assert PCI.IP.new(<<4 :: 4>>, 1,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using IP protocol string" do
    assert PCI.IP.new(<<4 :: 4>>, "icmp",
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using IP protocol atom" do
    assert PCI.IP.new(<<4 :: 4>>, :icmp,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using source IP string" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      "192.0.2.1", <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using source-mask IP string" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, "255.255.255.255",
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using source-mask integer" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, 32,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using destination IP string" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      "192.0.2.4", <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using destination-mask IP string" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, "255.255.255.255") ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI using destination-mask integer" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, 32) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI with src adjusted for src_mask" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xfffffff0::32>>,
                      <<192,0,2,4>>, <<0xffffffff::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,0>>, src_mask: <<0xfffffff0::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end
  test "new returns correct IPv4 PCI with dst adjusted for dst_mask" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>,
                      <<192,0,2,1>>, <<0xffffffff::32>>,
                      <<192,0,2,4>>, <<0xfffffff0::32>>) ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,0>>, dst_mask: <<0xfffffff0::32>>}
  end
  test "new returns correct IPv4 PCI with src/src_mask and dst/dst_mask as CIDR" do
    assert PCI.IP.new(<<4 :: 4>>, <<1>>, "192.0.2.1/32", "192.0.2.4/32") ==
      %PCI.IP{version: <<4 :: 4>>, proto: <<1>>,
              src: <<192,0,2,1>>, src_mask: <<0xffffffff::32>>,
              dst: <<192,0,2,4>>, dst_mask: <<0xffffffff::32>>}
  end

  test "new returns correct IPv6 PCI for binary arguments" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using version integer" do
    assert PCI.IP.new(6, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using IP protocol integer" do
    assert PCI.IP.new(<<6 :: 4>>, 1,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using IP protocol string" do
    assert PCI.IP.new(<<6 :: 4>>, "icmp",
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using source IP string" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      "fe80::1", <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using source-mask integer" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, 128,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using destination IP string" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>, 
                      "fe80::4", <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI using destination-mask integer" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>, 
                      <<0xfe,0x80,0::104,4>>, 128) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI with src adjusted for src_mask" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xfffffffffffffffffffffffffffffff0::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xffffffffffffffffffffffffffffffff::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,0>>, src_mask: <<0xfffffffffffffffffffffffffffffff0::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end
  test "new returns correct IPv6 PCI with dst adjusted for dst_mask" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>,
                      <<0xfe,0x80,0::104,1>>, <<0xffffffffffffffffffffffffffffffff::128>>,
                      <<0xfe,0x80,0::104,4>>, <<0xfffffffffffffffffffffffffffffff0::128>>) ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,0>>, dst_mask: <<0xfffffffffffffffffffffffffffffff0::128>>}
  end
  test "new returns correct IPv6 PCI with src/src_mask and dst/dst_mask as prefix" do
    assert PCI.IP.new(<<6 :: 4>>, <<1>>, "fe80::1/128", "fe80::4/128") ==
      %PCI.IP{version: <<6 :: 4>>, proto: <<1>>,
              src: <<0xfe,0x80,0::104,1>>, src_mask: <<0xffffffffffffffffffffffffffffffff::128>>,
              dst: <<0xfe,0x80,0::104,4>>, dst_mask: <<0xffffffffffffffffffffffffffffffff::128>>}
  end

  test "integer_to_binary_mask returns correct mask for mask_size at byte boundary" do
    assert PCI.IP.integer_to_binary_mask(40, 128) == <<0xffffffffff::40, 0::88>>
  end
  test "integer_to_binary_mask fails for non-integer mask" do
    assert_raise ArgumentError, "invalid argument: integer expected", fn ->
      PCI.IP.integer_to_binary_mask("a", 128)
    end
  end
  test "integer_to_binary_mask fails for non-integer mask_size" do
    assert_raise ArgumentError, "invalid argument: integer expected", fn ->
      PCI.IP.integer_to_binary_mask(1, "a")
    end
  end
  test "integer_to_binary_mask fails for mask_size not at byte boundary" do
    assert_raise ArgumentError, "invalid argument: mask_size must fall on byte boundary", fn ->
      PCI.IP.integer_to_binary_mask(40, 127)
    end
  end
end
