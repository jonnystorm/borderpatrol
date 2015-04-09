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
      {:urna, git: "https://github.com/meh/urna.git", ref: "fa2e99302c"},
      {:ecto, git: "https://github.com/elixir-lang/ecto.git", ref: "6d490c4c35"},
      {:postgrex, ">= 0.0.0"},
      {
        :net_snmp_ex,
        git: "https://github.com/jonnystorm/net-snmp-elixir.git",
        ref: "809d2122f4"
      },
      {
        :snmp_mib_ex,
        git: "https://github.com/jonnystorm/snmp-mib-elixir.git",
        ref: "a64115af59"
      },
      {
        :tftp_ex,
        git: "https://github.com/jonnystorm/tftp-elixir.git",
        ref: "20879d1364"
      },
      {
        :linear_ex,
        git: "https://github.com/jonnystorm/linear-elixir.git",
        ref: "4cca32d51a"
      }
    ]
  end
end
