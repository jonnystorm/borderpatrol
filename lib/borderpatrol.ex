# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(BorderPatrol.REST, []),
      worker(BorderPatrol.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: BorderPatrol.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

