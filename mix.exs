defmodule BorderPatrol.Mixfile do
  use Mix.Project

  def project do
    [app: :borderpatrol,
     version: "0.0.1",
     elixir: "~> 1.0", deps: deps]
  end

  def application do
    [applications: [:logger, :ecto],
     mod: {BorderPatrol, []}]
  end

  defp deps do
    [
      {:urna, git: "https://github.com/meh/urna"},
      {:ecto, "~> 1.0.0"},
      {:postgrex, ">= 0.0.0"},
      {:cisco_snmp_ex, git: "https://github.com/jonnystorm/cisco-snmp-elixir"},
      {:tftp_ex, git: "https://github.com/jonnystorm/tftp-elixir"},
      {:acl_ex, git: "https://github.com/jonnystorm/acl-elixir"},
      {:pathname_ex, git: "https://github.com/jonnystorm/pathname-elixir"}
    ]
  end
end
