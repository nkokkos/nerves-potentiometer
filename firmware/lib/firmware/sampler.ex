defmodule Firmware.Sampler do
  # create a worker that reads the voltage and 
  # broadcasts it via Phoenix PubSub. 
  # Notice how we use Pattern Matching to handle the sensor result

  use GenServer
  alias ADS1115.Server, as: ADC

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def init(_) do
    # Start the ADC driver on I2C bus 1
    {:ok, adc} = ADC.start_link(bus_name: "i2c-1", address: 0x48)
    send(self(), :sample)
    {:ok, adc}
  end

  def handle_info(:sample, adc) do
    # Read from A0. Pattern match the {:ok, value} tuple!
    case ADC.read(adc, :differential_0_1) do
      {:ok, value} ->
        # Broadcast to the Phoenix Web App
        Phoenix.PubSub.broadcast(Ui.PubSub, "voltage", {:new_reading, value})
      _error ->
        :skip
    end

    Process.send_after(self(), :sample, 100) # 10Hz sampling
    {:ok, adc}
  end
end
