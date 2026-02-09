defmodule NervesPotentiometerFirmware.MixProject do
  use Mix.Project

  @app :nerves_potentiometer_firmware
  @version "0.1.0"
  @target System.get_env("MIX_TARGET") || "host"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      build_embedded: @target != "host",
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  def application do
    [
      mod: {NervesPotentiometerFirmware.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      # Nerves dependencies
      {:nerves, "~> 1.11", runtime: false},
      {:nerves_system_rpi0_2, "~> 1.33", runtime: false, targets: :rpi0_2},
      {:nerves_system_rpi0, "~> 1.31", runtime: false, targets: :rpi0},
      {:nerves_system_rpi, "~> 1.31", runtime: false, targets: :rpi},
      {:nerves_system_rpi2, "~> 1.31", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.31", runtime: false, targets: :rpi3},
      {:nerves_system_rpi4, "~> 1.31", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.18", runtime: false, targets: :bbb},
      {:nerves_system_x86_64, "~> 1.31", runtime: false, targets: :x86_64},
      {:shoehorn, "~> 0.9"},
      {:ring_logger, "~> 0.11"},
      {:toolshed, "~> 0.4"},
      
      # UI project dependency (path dependency for poncho structure)
      {:nerves_potentiometer_ui, path: "../nerves_potentiometer_ui"},
      
      # Hardware dependencies
      {:elixir_ale, "~> 1.3"},
      {:circuits_i2c, "~> 2.0"},
      {:ads1115, "~> 0.3"},
      
      # Networking
      {:vintage_net, "~> 0.13"},
      {:nerves_network, "~> 0.7"},
      {:nerves_firmware_ssh, "~> 0.6"}
    ] ++ deps(@target)
  end

  defp deps("host"), do: []
  defp deps(target) do
    [
      {:nerves_runtime, "~> 0.13"}
    ] ++ system(target)
  end

  defp system("rpi0_2"), do: [{:nerves_system_rpi0_2, "~> 1.33", runtime: false}]
  defp system("rpi0"), do: [{:nerves_system_rpi0, "~> 1.31", runtime: false}]
  defp system("rpi"), do: [{:nerves_system_rpi, "~> 1.31", runtime: false}]
  defp system("rpi2"), do: [{:nerves_system_rpi2, "~> 1.31", runtime: false}]
  defp system("rpi3"), do: [{:nerves_system_rpi3, "~> 1.31", runtime: false}]
  defp system("rpi4"), do: [{:nerves_system_rpi4, "~> 1.31", runtime: false}]
  defp system("bbb"), do: [{:nerves_system_bbb, "~> 2.18", runtime: false}]
  defp system("x86_64"), do: [{:nerves_system_x86_64, "~> 1.31", runtime: false}]
  defp system(_), do: []

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      applications: [runtime_tools: :Permanent]
    ]
  end
end
