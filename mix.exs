defmodule BorderPatrol.Mixfile do
  use Mix.Project

  def project do
    [app: :borderpatrol,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :ecto],
     mod: {BorderPatrol, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:urna, git: "https://github.com/meh/urna.git", ref: "fa2e99302c"},
      {:ecto, git: "https://github.com/elixir-lang/ecto.git", ref: "6d490c4c35"},
      {:postgrex, ">= 0.0.0"}
    ]
  end
end
