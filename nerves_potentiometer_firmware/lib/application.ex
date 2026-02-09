defmodule NervesPotentiometerFirmware.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the UI application components (from UI project)
      NervesPotentiometerUi.PubSub,
      NervesPotentiometerUiWeb.Endpoint,
      
      # Start hardware-specific components
      {NervesPotentiometerFirmware.ADC, []},
      {NervesPotentiometerFirmware.PotentiometerReader, []}
    ]

    opts = [strategy: :one_for_one, name: NervesPotentiometerFirmware.Supervisor]
    Supervisor.start_link(children, opts)
  end
end