#!/bin/bash

# Build script for Nerves Potentiometer Poncho Project
# This script follows proper poncho project workflow

set -e

echo "🔧 Nerves Potentiometer Poncho Project Build Script"
echo "=================================================="

# Check if Nerves environment is set up
if ! command -v mix &> /dev/null; then
    echo "❌ Elixir/Mix not found. Please install Elixir first."
    exit 1
fi

# Step 1: Build UI assets (host only)
echo ""
echo "📦 Step 1: Building UI assets..."
cd nerves_potentiometer_ui

# Set host environment for UI development
export MIX_TARGET=host
export MIX_ENV=dev

echo "Installing UI dependencies..."
mix deps.get

echo "Building UI assets..."
mix assets.deploy

echo "✅ UI assets built successfully!"

# Step 2: Build firmware
echo ""
echo "🔨 Step 2: Building firmware..."
cd ../nerves_potentiometer_firmware

# Set target for Raspberry Pi Zero 2 Wireless
TARGET=${MIX_TARGET:-rpi0_2}
export MIX_TARGET=$TARGET
export MIX_ENV=prod

echo "Target: $TARGET"
echo "Installing firmware dependencies..."
mix deps.get

echo "Building firmware..."
mix firmware

echo "✅ Firmware built successfully!"
echo "📁 Firmware location: _build/$TARGET/prod/nerves/images/firmware.fw"

# Step 3: Deployment options
echo ""
echo "🚀 Step 3: Deployment Options:"
echo "1. Burn to SD card (requires SD card inserted)"
echo "2. Push to device (device must be on network)"
echo "3. Just build, no deployment"

read -p "Choose deployment method (1-3): " choice

case $choice in
    1)
        echo "🔥 Burning firmware to SD card..."
        mix firmware.burn
        echo "✅ Firmware burned to SD card!"
        ;;
    2)
        read -p "Enter device hostname (default: nerves-potentiometer.local): " HOST
        HOST=${HOST:-nerves-potentiometer.local}
        echo "📤 Pushing firmware to $HOST..."
        mix firmware.push $HOST
        echo "✅ Firmware pushed to device!"
        echo "🌐 Access at: http://$HOST:4000"
        ;;
    3)
        echo "🏁 Build complete. Firmware ready for manual deployment."
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "🎉 Build process completed!"
echo ""
echo "📋 Next steps:"
echo "1. Insert SD card into Raspberry Pi Zero Wireless"
echo "2. Connect potentiometer hardware:"
echo "   - Pi 3.3V → ADS1115 VDD"
echo "   - Pi GND → ADS1115 GND"  
echo "   - Pi GPIO 2 (SDA) → ADS1115 SDA"
echo "   - Pi GPIO 3 (SCL) → ADS1115 SCL"
echo "   - Potentiometer wiper → ADS1115 A0"
echo "   - Potentiometer outer pins → 5V and GND"
echo "3. Power on the device"
echo "4. Access LiveView at: http://nerves-potentiometer.local:4000"
echo "5. For UI development only: cd nerves_potentiometer_ui && mix phx.server"
echo ""
echo "💡 Poncho Project Benefits:"
echo "   - UI can be developed without hardware"
echo "   - Clear separation of concerns"
echo "   - Proper asset handling"
echo "   - Team-friendly workflow"