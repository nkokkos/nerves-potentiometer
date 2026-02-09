# This is a project in progress and everything is breaking...

# A Simple Nerves + Phoenix + LiveView application that:
- Reads potentiometer voltage via ADS1115 ADC every 100ms
- Displays real-time graph in web browser
- Shows min/max/current statistics
- Provides LiveBook notebook for data analysis
- Scales to 0-5V range
- Works on Raspberry Pi Zero Wireless

# Nerves Potentiometer - Poncho Project Structure

This project follows the **poncho project pattern** for Nerves applications with Phoenix UI.

## What is a Poncho Project?

A poncho project is an alternative to umbrella projects that uses separate Mix projects side-by-side with path dependencies between them. This is the **preferred structure** for Nerves + Phoenix applications.

## Project Structure

```
In Progress
```

## Why Poncho Over Umbrella?

1. **Clear Separation**: UI can be developed without hardware
2. **Proper Asset Handling**: Assets built on host, embedded in firmware
3. **Target-Specific Dependencies**: Nerves deps only in firmware, dev deps only in UI
4. **Simpler Configuration**: No complex umbrella config merging
5. **Team Workflows**: Frontend and embedded teams can work independently

## Development Workflow

### UI Development (No Hardware Required)
```bash
cd nerves_potentiometer_ui
mix deps.get
mix phx.server
# Access http://localhost:4000
```

### Firmware Development
```bash
cd nerves_potentiometer_firmware
export MIX_TARGET=rpi0_2
mix deps.get
mix firmware
mix firmware.burn
```

### Full Build & Deploy
```bash
./build.sh
```

## Key Principles

1. **Firmware Project**: Contains only embedded-specific code (I2C, ADC, networking)
2. **UI Project**: Pure Phoenix web application (LiveView, assets, routes)
3. **Path Dependency**: Firmware depends on UI via `path: "../nerves_potentiometer_ui"`
4. **Configuration**: Firmware imports UI config, then overrides for embedded deployment
5. **Asset Pipeline**: Assets built in UI project, deployed with firmware

## Hardware Setup

- Raspberry Pi Zero Wireless
- ADS1115 ADC (I2C address 0x48)
- 10kΩ potentiometer on A0 input
- 5V power to potentiometer

This poncho structure provides maximum flexibility and follows Nerves best practices.
