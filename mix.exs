defmodule EctoSoftDelete.Mixfile do
  use Mix.Project

  def project do
    [app: :ecto_soft_delete,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:ecto, :postgrex]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1.0-rc.1"},
      {:postgrex, ">= 0.0.0", only: [:test]},
      {:ex_doc, "~> 0.14.1", only: [:dev, :test]},
      {:earmark, "~> 1.0", only: [:dev, :test]},
      {:credo, "~> 0.4.11", only: [:dev, :test]},
      {:excoveralls, "~> 0.5.6", only: [:dev, :test]}
    ]
  end
end
