defmodule PCI do
  defmodule IP do
    defstruct version: nil, proto: nil, proto_mask: nil,
              src: nil, src_mask: nil, dst: nil, dst_mask: nil
    @type t :: %IP{version: <<_::4>>, proto: <<_::8>>, proto_mask: <<_::8>>,
                   src: binary, src_mask: binary, dst: binary, dst_mask: binary}

    #@spec new(6, <<_ :: 8>>, <<_ :: 16 * 8>>, <<_ :: 16 * 8>>) :: IP.t
    #@spec new(<<6 :: 4>>, 0..255, <<_ :: 16 * 8>>, <<_ :: 16 * 8>>) :: IP.t
    #@spec new(<<6 :: 4>>, <<_ :: 8>>, <<_ :: 16 * 8>>, <<_ :: 16 * 8>>) :: IP.t
    #@spec new(4, <<_ :: 8>>, <<_ :: 4 * 8>>, <<_ :: 4 * 8>>) :: IP.t
    #@spec new(<<4 :: 4>>, 0..255, <<_ :: 4 * 8>>, <<_ :: 4 * 8>>) :: IP.t
    #@spec new(<<4 :: 4>>, <<_ :: 8>>, <<_ :: 4 * 8>>, <<_ :: 4 * 8>>) :: IP.t
    def new(version, protocol, source, destination) do
      [source_str, source_mask_str] = :binary.split(source, "/")
      [destination_str, destination_mask_str] = :binary.split(destination, "/")
      source_mask = String.to_integer(source_mask_str)
      destination_mask = String.to_integer(destination_mask_str)

      new(version, protocol,
          source_str, source_mask, destination_str, destination_mask)
    end
    def new(version, protocol,
            source, source_mask, destination, destination_mask)
        when version in [4, 6] do
      new(<<version :: 4>>, protocol,
          source, source_mask, destination, destination_mask)
    end
    def new(version, protocol,
            source, source_mask, destination, destination_mask)
        when protocol in 0..255 do
      new(version, <<protocol>>,
          source, source_mask, destination, destination_mask)
    end
    def new(version, protocol,
            source, source_mask, destination, destination_mask)
        when byte_size(protocol) > 1 do
      new(version, ip_proto_keyword_to_number(protocol),
          source, source_mask, destination, destination_mask)
    end
    def new(version, protocol,
            source, source_mask, destination, destination_mask)
        when is_atom(protocol) do
      new(version, ip_proto_keyword_to_number(protocol),
          source, source_mask, destination, destination_mask)
    end
    def new(<<4 :: 4>>, protocol,
            source, source_mask, destination, destination_mask) do
      if is_ipv4_string(source) do
        {:ok, source} = string_to_ipv4(source)
      end
      if is_ipv4_string(source_mask) do
        {:ok, source_mask} = string_to_ipv4(source_mask)
      end
      if source_mask in 0..32 do
        source_mask = integer_to_binary_mask(source_mask, 32)
      end
      if is_ipv4_string(destination) do
        {:ok, destination} = string_to_ipv4(destination)
      end
      if is_ipv4_string(destination_mask) do
        {:ok, destination_mask} = string_to_ipv4(destination_mask)
      end
      if destination_mask in 0..32 do
        destination_mask = integer_to_binary_mask(destination_mask, 32)
      end
      source = Vector.bit_and(source, source_mask)
      destination = Vector.bit_and(destination, destination_mask)

      %IP{version: <<4 :: 4>>, proto: protocol,
          src: source, src_mask: source_mask,
          dst: destination, dst_mask: destination_mask}
    end
    def new(<<6 :: 4>>, protocol,
            source, source_mask, destination, destination_mask) do
      if is_ipv6_string(source) do
        {:ok, source} = string_to_ipv6(source)
      end
      if is_ipv6_string(source_mask) do
        {:ok, source_mask} = string_to_ipv6(source_mask)
      end
      if source_mask in 0..128 do
        source_mask = integer_to_binary_mask(source_mask, 128)
      end
      if is_ipv6_string(destination) do
        {:ok, destination} = string_to_ipv6(destination)
      end
      if is_ipv6_string(destination_mask) do
        {:ok, destination_mask} = string_to_ipv6(destination_mask)
      end
      if destination_mask in 0..128 do
        destination_mask = integer_to_binary_mask(destination_mask, 128)
      end
      source = Vector.bit_and(source, source_mask)
      destination = Vector.bit_and(destination, destination_mask)

      %IP{version: <<6 :: 4>>, proto: protocol,
          src: source, src_mask: source_mask,
          dst: destination, dst_mask: destination_mask}
    end

    @spec integer_to_binary_mask(non_neg_integer, pos_integer) :: binary
    def integer_to_binary_mask(int, mask_size)
        when is_integer(int)
         and rem(mask_size, 8) == 0 do
      ones = trunc(:math.pow(2, mask_size)) - 1
      zero_count = mask_size - int

      <<ones::size(int), 0::size(zero_count)>>
    end
    def integer_to_binary_mask(_, mask_size) do
      if is_integer(mask_size) && rem(mask_size, 8) != 0 do
        message = "invalid argument: mask_size must fall on byte boundary"
      else
        message = "invalid argument: integer expected"
      end

      raise ArgumentError, message: message
    end

    #@spec version(IP.t) :: <<4 :: 4>> | <<6 :: 4>>
    def version(pci), do: pci.version

    @spec protocol(IP.t) :: <<_ :: 8>>
    def protocol(pci), do: pci.proto

    @spec source(IP.t) :: <<_ :: 4 * 8>> | <<_ :: 16 * 8>>
    def source(pci), do: pci.src

    @spec destination(IP.t) :: <<_ :: 4 * 8>> | <<_ :: 16 * 8>>
    def destination(pci), do: pci.dst

    @spec ipv4_to_string(<<_ :: 4 * 8>>) :: String.t
    def ipv4_to_string(ip) when is_binary(ip) do
      ip
        |> :binary.bin_to_list
        |> Enum.join(".")
    end

    @spec ipv6_to_string(<<_ :: 16 * 8>>) :: String.t
    def ipv6_to_string(ip) when is_binary(ip) do
      ip
        |> :binary.bin_to_list
        |> Enum.join(":")
        |> String.replace(~r/(0:)+/, ":")
    end

    def contains_only?(string, characters)
        when is_binary(string) and is_binary(characters) do
      char_list = :binary.bin_to_list(characters)
      string
        |> :binary.bin_to_list
        |> Enum.all?(&(&1 in char_list))
    end

    @spec integer_to_bytes(integer) :: <<_ :: 8>>
    def integer_to_bytes(int) when is_integer(int) do
      if int == 0, do: <<0>>
      int
        |> Stream.unfold(fn 0 -> nil; x -> {rem(x, 256), div(x, 256)} end)
        |> Enum.to_list
        |> Enum.reverse
        |> :binary.list_to_bin
    end

    @spec expand_ipv6_string(String.t) :: String.t
    def expand_ipv6_string(string) when is_binary(string) do
      sep_count = string
        |> :binary.split(":", [:global])
        |> length
      zero_word_count = 8 - sep_count + 1

      case :binary.split(string, "::", [:global]) do
        [first, last] ->
          zero_words = (for _ <- 1..zero_word_count, do: ":0") |> Enum.join
          expanded = first <> zero_words <> ":" <> last

          if String.last(expanded) == ":" do
            expanded <> "0"
          else
            expanded
          end
        _ ->
          string
      end
    end

    @spec is_ipv6_string(String.t) :: boolean
    def is_ipv6_string(string) when is_binary(string) do
      words = string
        |> expand_ipv6_string
        |> :binary.split(":", [:global])

      contains_only?(string, "0123456789abcdefABCDEF:")
        and length(words) == 8
        and Enum.all?(words, &(String.length(&1) > 0))
        and Enum.all?(words, &(String.length(&1) <= 4))
    end
    def is_ipv6_string(_), do: false

    defp string_to_byteword(string, base) do
      string
        |> String.to_integer(base)
        |> integer_to_bytes
        |> String.rjust(2, 0)
    end

    defp _string_to_ipv6(<<>>, {cur_word_str, acc}) do
      acc <> string_to_byteword(cur_word_str, 16)
    end
    defp _string_to_ipv6(<<char, tail :: binary>>, {cur_word_str, acc}) do
      case char do
        ?: ->
          if cur_word_str == <<>> do
            _string_to_ipv6(tail, {<<>>, acc}) 
          else
            _string_to_ipv6(tail, {<<>>, acc <> string_to_byteword(cur_word_str, 16)})
          end
        _ ->
          _string_to_ipv6(tail, {cur_word_str <> <<char>>, acc})
      end
    end

    @spec string_to_ipv6(String.t) :: {:ok, <<_ :: 16 * 8>>} | {:error, :badarg}
    def string_to_ipv6(string) when is_binary(string) do
      case is_ipv6_string(string) do
        true ->
          {:ok, _string_to_ipv6(expand_ipv6_string(string), {<<>>, <<>>})}
        false ->
          {:error, :badarg}
      end
    end

    @spec is_ipv4_string(String.t) :: boolean
    def is_ipv4_string(string) when is_binary(string) do
      octets = :binary.split(string, ".", [:global])

      contains_only?(string, "0123456789.")
        and length(octets) == 4
        and Enum.all?(octets, &(&1 != "" && String.to_integer(&1) in 0..255))
    end
    def is_ipv4_string(_), do: false

    @spec string_to_ipv4(String.t) :: {:ok, <<_ :: 4 * 8>>} | {:error, :badarg}
    def string_to_ipv4(string) when is_binary(string) do
      case is_ipv4_string(string) do
        true ->
          ip = string
            |> :binary.split(".", [:global])
            |> Enum.map(&(String.to_integer &1))
            |> :binary.list_to_bin

          {:ok, ip}
        false ->
          {:error, :badarg}
      end
    end

    defp ip_proto_num_to_kw_map do
      %{
        0x1  => "icmp",
        0x6  => "tcp",
        0x11 => "udp"
      }
    end

    defp ip_proto_kw_to_num_map do
      %{
        icmp: 0x1,
        tcp: 0x6,
        udp: 0x11
      }
    end

    @spec ip_proto_number_to_keyword(<<_ :: 8>>) :: String.t | nil
    def ip_proto_number_to_keyword(<<proto :: 4>>) do
      ip_proto_num_to_kw_map[proto]
    end
    @spec ip_proto_number_to_keyword(0..255) :: String.t | nil
    def ip_proto_number_to_keyword(proto) when is_integer(proto) do
      ip_proto_num_to_kw_map[proto]
    end

    @spec ip_proto_keyword_to_number(atom) :: 0..255
    def ip_proto_keyword_to_number(keyword) when is_atom(keyword) do
      ip_proto_kw_to_num_map[keyword]
    end
    @spec ip_proto_keyword_to_number(String.t) :: 0..255
    def ip_proto_keyword_to_number(keyword) when is_binary(keyword) do
      key = keyword
        |> String.downcase
        |> String.to_atom
      ip_proto_kw_to_num_map[key]
    end
  end

  defmodule ICMP do
    defstruct type: <<0>>, code: <<0>>
    @type t :: %ICMP{type: <<_ :: 8>>, code: <<_ :: 8>>}

    def new(type, code) when type in 0..255 and code in 0..255 do
      new(<<type>>, <<code>>)
    end
    def new(type, code) when byte_size(type) == 1 and byte_size(code) == 1 do
      %ICMP{type: type, code: code}
    end
  end

  defmodule TCP do
    defstruct src: <<0::16>>, dst: <<0::16>>
    @type t :: %TCP{src: <<_::16>>, dst: <<_::16>>}

    def new(source, destination)
        when source in 0..0xffff and destination in 0..0xffff do
      new(<<source::16>>, <<destination::16>>)
    end
    def new(source, destination)
        when byte_size(source) == 2 and byte_size(destination) == 2 do
      %TCP{src: source, dst: destination}
    end
  end

  defmodule UDP do
    defstruct src: <<0::16>>, src_mask: <<65535::16>>,
              dst: <<0::16>>, dst_mask: <<65535::16>>
    @type t :: %UDP{src: <<_::16>>, src_mask: <<_::16>>,
                    dst: <<_::16>>, dst_mask: <<_::16>>}

    def new(source, destination) do
      new(source, <<0xffff::16>>, destination, <<0xffff::16>>)
    end
    def new(source, source_mask, destination, destination_mask)
        when source in 0..0xffff and destination in 0..0xffff do
      new(<<source::16>>, source_mask, <<destination::16>>, destination_mask)
    end
    def new(source, source_mask, destination, destination_mask)
        when byte_size(source) == 2 and byte_size(destination) == 2 do
      %UDP{src: source, src_mask: source_mask,
           dst: destination, dst_mask: destination_mask}
    end
  end
end

acl = [permit: [PCI.IP.new(4, :tcp, "192.0.2.0/24", "192.0.2.0/24"),
                PCI.TCP.new(38443, 443)],
       permit: [PCI.IP.new(6, :udp, "fe80::2:0/40", "fe80::2:0/40"),
                PCI.UDP.new(8000, 69)]
      ]

defmodule ACL do
  defstruct action: :permit
end

