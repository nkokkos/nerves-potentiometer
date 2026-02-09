use Mix.Config

config :nerves_potentiometer_ui, NervesPotentiometerUiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    view: NervesPotentiometerUiWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: NervesPotentiometerUi.PubSub,
  live_view: [signing_salt: "potentiometer_salt"]

config :phoenix, :json_library, Jason

config :logger, level: :debug

import_config "#{config_env()}.exs"
