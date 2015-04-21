use Mix.Config

config :borderpatrol, Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "borderpatrol",
  username: "borderpatrol",
  password: "borderpatrol",
  extensions: [{Extensions.Inet, []}, {Extensions.MacAddr, []}]

config :borderpatrol, BorderPatrol.REST, port: 8080

