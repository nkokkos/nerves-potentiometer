defmodule NervesPotentiometerUi.MixProject do
  use Mix.Project

  @app :nerves_potentiometer_ui
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {NervesPotentiometerUi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Phoenix dependencies
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_live_reload, "~> 1.5", only: :dev, targets: [:host]},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:plug_cowboy, "~> 2.6"},
      {:jason, "~> 1.4"},
      
      # Asset handling (only on host)
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev && Mix.target() == :host},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev && Mix.target() == :host},
      
      # Testing
      {:ex_unit, "~> 1.8", only: :test},
      {:floki, ">= 0.30.0", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
