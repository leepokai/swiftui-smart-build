#!/bin/bash
# Launch script for Smart Build plugin
# Usage: launch.sh <device_type> <device_id_or_name> <bundle_id>

set -e

DEVICE_TYPE="$1"
DEVICE_ID="$2"
BUNDLE_ID="$3"

if [ -z "$DEVICE_TYPE" ] || [ -z "$DEVICE_ID" ] || [ -z "$BUNDLE_ID" ]; then
    echo "Usage: launch.sh <device_type> <device_id_or_name> <bundle_id>"
    echo "Example: launch.sh simulator 'iPhone 16 Pro' com.example.MyApp"
    exit 1
fi

echo "Launching..."
echo "  Device: $DEVICE_ID ($DEVICE_TYPE)"
echo "  Bundle: $BUNDLE_ID"
echo ""

if [ "$DEVICE_TYPE" = "simulator" ]; then
    # Terminate existing instance
    xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true

    # Launch
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

    # Open Simulator app
    open -a Simulator

    echo "LAUNCH SUCCEEDED"
else
    # Real device (iOS 17+)
    xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID"
    echo "LAUNCH SUCCEEDED"
fi
