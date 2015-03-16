# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defprotocol Vector do
  def add(vector1, vector2)
  def bit_and(vector1, vector2)
  def inner(vector1, vector2)
  def outer(vector1, vector2)
  def subtract(vector1, vector2)
  def bit_xor(vector1, vector2)
end

defimpl Vector, for: BitString do
  use Bitwise

  defp vector_op(list1, list2, fun) do
    Enum.zip(list1, list2)
      |> Enum.map(fun)
  end

  defp bitstrings_to_lists(bitstrings) do
    bitstrings
      |> Enum.map(&(:binary.bin_to_list &1))
  end

  def add(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    vector_op(u, v, fn {ui, vi} -> ui + vi end)
      |> :binary.list_to_bin
  end
  
  def bit_and(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    vector_op(u, v, fn {ui, vi} -> band(ui, vi) end)
      |> :binary.list_to_bin
  end

  def inner(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    vector_op(u, v, fn {ui, vi} -> ui * vi end)
      |> Enum.sum
  end

  def outer(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    (for ui <- u do
      for vj <- v, do: ui * vj
    end) |> :binary.list_to_bin
  end

  def subtract(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    vector_op(u, v, fn {ui, vi} -> ui - vi end)
      |> :binary.list_to_bin
  end

  def bit_xor(bitstring1, bitstring2) do
    [u, v] = [bitstring1, bitstring2]
      |> bitstrings_to_lists

    vector_op(u, v, fn {ui, vi} -> bxor(ui, vi) end)
      |> :binary.list_to_bin
  end
end

defimpl Vector, for: List do
  use Bitwise

  defp vector_op(list1, list2, fun) when is_list(list1) and is_list(list2) do
    Enum.zip(list1, list2)
      |> Enum.map(fun)
  end

  def add(list1, list2) when is_list(list1) and is_list(list2) do
    vector_op(list1, list2, fn {ui, vi} -> ui + vi end)
  end

  def bit_and(list1, list2) when is_list(list1) and is_list(list2) do
    vector_op(list1, list2, fn {ui, vi} -> band(ui, vi) end)
  end

  def inner(list1, list2) when is_list(list1) and is_list(list2) do
    vector_op(list1, list2, fn {ui, vi} -> ui * vi end)
      |> Enum.sum
  end

  def subtract(list1, list2) when is_list(list1) and is_list(list2) do
    vector_op(list1, list2, fn {ui, vi} -> ui - vi end)
  end

  def bit_xor(list1, list2) when is_list(list1) and is_list(list2) do
    vector_op(list1, list2, fn {ui, vi} -> bxor(ui, vi) end)
  end

  def outer(list1, list2) when is_list(list1) and is_list(list2) do
    [u, v] = [list1, list2]

    (for ui <- u do
      for vj <- v, do: ui * vj
    end) |> List.flatten
  end
end


defmodule Matrix do
  def dimension(matrix) when is_list(matrix) do
    [row|_tail] = matrix

    {length(matrix), length(row)}
  end

  def multiply([row|_t], [row2|_t2]) when is_list(row) and is_list(row2) do
    for row <- [row|_t] do
      for col <- transpose([row2|_t2]) do
        Vector.inner(row, col)
      end
    end
  end
  def multiply([row|_tail], vector) when is_list(row) and is_list(vector) do
    multiply([row|_tail], transpose([vector]))
  end

  def transpose([row|_tail]) when is_list(row) do
    [row|_tail]
      |> List.zip
      |> Enum.map(&(Tuple.to_list &1))
  end
  def transpose(vector) when is_list(vector), do: transpose([vector])
end

