defmodule Taxlotter.MixProject do
  use Mix.Project

  def project do
    [
      app: :taxlotter,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def escript do
    [main_module: TaxLotter.CLI]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :bunt]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_csv, "~> 1.1"},
      {:bunt, "~> 0.2.0"},
      {:decimal, "~> 2.0"},
      {:ecto, "~> 3.10"}
    ]
  end
end
