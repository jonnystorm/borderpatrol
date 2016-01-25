defmodule BorderPatrol.Mixfile do
  use Mix.Project

  def project do
    [app: :borderpatrol,
     version: "0.0.8",
     elixir: "~> 1.0", deps: deps]
  end

  defp get_application(:prod) do
    [
      applications: [
        :logger,
        :urna,
        :cauldron,
        :ecto,
        :postgrex,
        :connection,
        :cisco_snmp_ex,
        :tftp_ex,
        :acl_ex
      ],
      mod: {BorderPatrol, []}
    ]
  end
  defp get_application(_) do
    [applications: [:logger]]
  end

  def application do
    get_application Mix.env
  end

  defp deps do
    [
      {:urna, git: "https://github.com/meh/urna", ref: "cceb5ef10b"},
      {:cauldron, "~> 0.1.5"},
      {:ecto, "~> 1.1.0"},
      {:postgrex, "~> 0.11.0"},
      {:cisco_snmp_ex, git: "https://github.com/jonnystorm/cisco-snmp-elixir"},
      {:tftp_ex, git: "https://github.com/jonnystorm/tftp-elixir"},
      {:acl_ex, git: "https://github.com/jonnystorm/acl-elixir"}
    ]
  end
end
