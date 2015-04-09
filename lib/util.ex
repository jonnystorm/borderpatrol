# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Util do
  def ipv4_regex do
    octet = "(1?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])"

    ~r/^(#{octet}\.){3}#{octet}$/
  end

  def mac_regex do
    ~r/^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/
  end

  def iso_8601_regex do
    year_str = "[0-9]{4}-([0-9]|1[0-2])-([1-2]?[0-9]|3[0-1])"
    time_str = "([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]"
    offset_str = "([\-\+][0-9]{1,4}|Z)"

    ~r/^#{year_str}T#{time_str}#{offset_str}$/
  end

  def flat_zip(list1, list2) do
    list1
      |> Enum.zip(list2)
      |> Enum.map(&(Tuple.to_list &1))
      |> List.flatten
  end
end
