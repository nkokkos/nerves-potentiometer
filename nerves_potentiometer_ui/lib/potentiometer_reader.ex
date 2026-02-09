defmodule NervesPotentiometerUi.PotentiometerReader do
  @moduledoc """
  Mock potentiometer reader for UI development.
  In production, this is replaced by the firmware version.
  """
  use GenServer
  require Logger

  @read_interval_ms 100

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Only start if running in development without hardware
    if Mix.target() == :host do
      {:ok, ref} = :timer.send_interval(@read_interval_ms, :generate_reading)
      {:ok, %{timer_ref: ref}}
    else
      :ignore
    end
  end

  @impl true
  def handle_info(:generate_reading, state) do
    # Simulate potentiometer values between 0-5V
    voltage = :rand.uniform(500) / 100.0 + (:rand.uniform(20) - 10) / 100.0
    voltage = max(0, min(5, voltage))
    
    reading = %{
      voltage: voltage,
      timestamp: DateTime.utc_now(),
      raw_adc: round((voltage / 5.0) * 32767)
    }
    
    # Publish to PubSub for LiveView
    Phoenix.PubSub.broadcast(
      NervesPotentiometerUi.PubSub,
      "potentiometer_readings",
      {:new_reading, reading}
    )
    
    Logger.debug("Mock potentiometer reading: #{voltage}V")
    {:noreply, state}
  end
end