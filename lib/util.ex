# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule Util do
  def get_key_by_value(dict, value) do
    dict
      |> Enum.find(fn {_k, v} -> v == value end)
      |> (fn {k, _v} -> k end).()
  end

  def shell_cmd(command) do
    command
      |> :binary.bin_to_list
      |> :os.cmd
      |> :binary.list_to_bin
  end
end
