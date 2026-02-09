use Mix.Config

# Target-specific configuration for Raspberry Pi Zero 2 Wireless
# This file is only loaded when MIX_TARGET=rpi0_2

# Configure networking
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

# Enable the logger
config :logger, level: :debug

# Configure I2C for ADS1115 on the target
config :circuits_i2c, 
  detect_devices: true