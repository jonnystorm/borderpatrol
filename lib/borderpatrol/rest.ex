# Copyright © 2015 Jonathan Storm <the.jonathan.storm@gmail.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the COPYING.WTFPL file for more details.

defmodule BorderPatrol.REST do
  use Urna, allow: [
    headers: true,
    methods: true,
    credentials: true,
    origins: ["http://localhost:8888"]
  ]

  resource :provision do
    post do
      params |> reply 200
    end
  end

  def start_link do
    Urna.start BorderPatrol.REST, port: 8080
  end
end

