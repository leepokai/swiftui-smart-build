#!/bin/bash
# Install script for Smart Build plugin
# Usage: install.sh <device_type> <device_id_or_name> <app_path>

set -e

DEVICE_TYPE="$1"
DEVICE_ID="$2"
APP_PATH="$3"

if [ -z "$DEVICE_TYPE" ] || [ -z "$DEVICE_ID" ] || [ -z "$APP_PATH" ]; then
    echo "Usage: install.sh <device_type> <device_id_or_name> <app_path>"
    echo "Example: install.sh simulator 'iPhone 16 Pro' /path/to/MyApp.app"
    exit 1
fi

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: App not found at $APP_PATH"
    exit 1
fi

echo "Installing..."
echo "  Device: $DEVICE_ID ($DEVICE_TYPE)"
echo "  App: $APP_PATH"
echo ""

if [ "$DEVICE_TYPE" = "simulator" ]; then
    # Boot simulator if needed
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true

    # Install
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"

    echo "INSTALL SUCCEEDED"
else
    # Real device (iOS 17+)
    xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"
    echo "INSTALL SUCCEEDED"
fi
