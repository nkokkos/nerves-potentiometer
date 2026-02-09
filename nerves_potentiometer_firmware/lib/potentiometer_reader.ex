defmodule NervesPotentiometerFirmware.PotentiometerReader do
  @moduledoc """
  Continuously reads potentiometer values and publishes them
  """
  use GenServer
  require Logger

  @read_interval_ms 100

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, ref} = :timer.send_interval(@read_interval_ms, :read_potentiometer)
    state = %{timer_ref: ref}
    Logger.info("Potentiometer reader started")
    {:ok, state}
  end

  @impl true
  def handle_info(:read_potentiometer, state) do
    case NervesPotentiometerFirmware.ADC.read_voltage_a0() do
      voltage when is_number(voltage) ->
        reading = %{
          voltage: voltage,
          timestamp: DateTime.utc_now(),
          raw_adc: round((voltage / 4.096) * 32767)
        }
        
        # Publish to PubSub (from UI project)
        Phoenix.PubSub.broadcast(
          NervesPotentiometerUi.PubSub,
          "potentiometer_readings",
          {:new_reading, reading}
        )
        
        Logger.debug("Potentiometer reading: #{voltage}V")
        
      nil ->
        Logger.debug("Failed to read potentiometer - retrying")
        
      error ->
        Logger.error("Unexpected error reading potentiometer: #{inspect(error)}")
    end
    
    {:noreply, state}
  end

  def get_current_reading do
    GenServer.call(__MODULE__, :get_current)
  end

  @impl true
  def handle_call(:get_current, _from, state) do
    case NervesPotentiometerFirmware.ADC.read_voltage_a0() do
      voltage when is_number(voltage) ->
        reading = %{
          voltage: voltage,
          timestamp: DateTime.utc_now(),
          raw_adc: round((voltage / 4.096) * 32767)
        }
        {:reply, {:ok, reading}, state}
        
      nil ->
        {:reply, {:error, :reading_failed}, state}
    end
  end
end