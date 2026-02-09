defmodule NervesPotentiometerFirmware.ADC do
  @moduledoc """
  Interface for ADS1115 ADC chip connected via I2C
  """
  use GenServer
  require Logger

  @ads1115_address 0x48
  @conversion_register 0x00
  @config_register 0x01
  @config_default <<0xC1, 0x83>>

  defstruct [:i2c_bus, :address]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    case Circuits.I2C.open("i2c-1") do
      {:ok, i2c} ->
        # Configure ADS1115 for single-ended input on A0, +/-4.096V range, 128 SPS
        case Circuits.I2C.write(i2c, @ads1115_address, <<@config_register>> <> @config_default) do
          :ok ->
            state = %__MODULE__{i2c_bus: i2c, address: @ads1115_address}
            Logger.info("ADS1115 ADC initialized successfully")
            {:ok, state}
          
          {:error, reason} ->
            Logger.error("Failed to initialize ADS1115: #{inspect(reason)}")
            {:error, reason}
        end
      
      {:error, reason} ->
        Logger.error("Failed to open I2C bus: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def read_voltage_a0 do
    GenServer.call(__MODULE__, :read_a0)
  end

  @impl true
  def handle_call(:read_a0, _from, state) do
    voltage = read_adc_value(state)
    {:reply, voltage, state}
  end

  defp read_adc_value(state) do
    try do
      # Start conversion
      config = <<0xC1, 0x83>>
      case Circuits.I2C.write(state.i2c_bus, state.address, <<@config_register>> <> config) do
        :ok ->
          # Wait for conversion to complete (simple delay)
          Process.sleep(10)
          
          # Read conversion result (2 bytes)
          case Circuits.I2C.read(state.i2c_bus, state.address, 2) do
            {:ok, <<msb::8, lsb::8>>} ->
              raw_value = (msb <<< 8) ||| lsb
              
              # Convert to voltage (assuming +/-4.096V range, 16-bit signed)
              voltage = (raw_value / 32767.0) * 4.096
              
              # Ensure voltage is positive for single-ended input
              voltage = max(0, voltage)
              
              Logger.debug("Raw ADC value: #{raw_value}, Voltage: #{voltage}V")
              voltage
            
            {:error, reason} ->
              Logger.error("Failed to read ADC: #{inspect(reason)}")
              nil
          end
        
        {:error, reason} ->
          Logger.error("Failed to start ADC conversion: #{inspect(reason)}")
          nil
      end
    rescue
      error ->
        Logger.error("ADC error: #{inspect(error)}")
        nil
    end
  end
end
