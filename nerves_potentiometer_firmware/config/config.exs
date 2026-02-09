use Mix.Config

# Import UI project configuration
import_config "../nerves_potentiometer_ui/config/config.exs"

# Configure the target for Raspberry Pi Zero 2 Wireless
config :nerves, :target, :rpi0_2

# Configure WiFi - set environment variables or edit directly
config :vintage_net,
  config: [
    {"wlan0", %{
      type: VintageNetWiFi,
      vintage_net_wifi: %{
        networks: [
          %{
            ssid: System.get_env("NERVES_WIFI_SSID") || "YOUR_WIFI_SSID",
            psk: System.get_env("NERVES_WIFI_PSK") || "YOUR_WIFI_PASSWORD",
            key_mgmt: :wpa_psk
          }
        ]
      },
      ipv4: %{method: :dhcp}
    }}
  ]

# Override UI Phoenix endpoint for embedded deployment
config :nerves_potentiometer_ui, NervesPotentiometerUiWeb.Endpoint,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  url: [host: "nerves-potentiometer.local"],
  http: [ip: {0, 0, 0, 0}, port: 4000],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "potentiometer_secret_key_change_in_production",
  live_view: [signing_salt: "potentiometer_salt"],
  check_origin: false,
  render_errors: [
    view: NervesPotentiometerUiWeb.ErrorView, 
    accepts: ~w(html json), 
    layout: false
  ],
  pubsub_server: NervesPotentiometerUi.PubSub,
  # Start the server since we're running in a release instead of through `mix`
  server: true,
  # Nerves root filesystem is read-only, so disable the code reloader
  code_reloader: false

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure firmware SSH
config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.expand("~/.ssh/id_rsa.pub"))
    |> String.trim()
  ]

# Configure RingLogger
config :ring_logger, :default,
  max_size: 1000

# Configure heart monitoring
config :nerves_heart, :pubsub,
  name: NervesPotentiometerUi.PubSub

import_config "#{config_target()}.exs"
