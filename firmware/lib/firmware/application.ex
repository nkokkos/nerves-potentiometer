defmodule Firmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do

   #Let's set up Livebook password optional but recommended
   System.put_env("LIVEBOOK_PASSWORD", "nerves")

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Firmware.Worker.start_link(arg)
        # {Firmware.Worker, arg},
  
    	# 1. Start the Phoenix PubSub (Crucial for communication)
    	  {Phoenix.PubSub, name: Ui.PubSub},

    	# 2. Start the Sampler (The "Logic" that talks to the hardware)
    	  Firmware.Sampler,

    	# 3. Start the UI Endpoint (The Phoenix Server)
    	  UiWeb.Endpoint,

    	# 4. Start Livebook (The REPL/Notebook)
    	  {Livebook.Application, []},       


      ] ++ target_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported optionsi

    # Please note that the strategy: :one_for_one means if the ADS1115 sampler 
    # crashes because a wire came loose, the 
    # supervisor will kill just that process and restart it
    opts = [strategy: :one_for_one, name: Firmware.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  if Mix.target() == :host do
    defp target_children() do
      [
        # Children that only run on the host during development or test.
        # In general, prefer using `config/host.exs` for differences.
        #
        # Starts a worker by calling: Host.Worker.start_link(arg)
        # {Host.Worker, arg},
      ]
    end
  else
    defp target_children() do
      [
        # Children for all targets except host
        # Starts a worker by calling: Target.Worker.start_link(arg)
        # {Target.Worker, arg},
      ]
    end
  end
end
