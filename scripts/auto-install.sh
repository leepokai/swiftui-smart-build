#!/bin/bash

# Auto-install script for Stop hook
# Only installs if a marker file exists (created by Claude after successful build)

MARKER_FILE="/tmp/.claude-install-ready-${CLAUDE_SESSION_ID:-default}.json"

# Check if marker file exists
if [ ! -f "$MARKER_FILE" ]; then
    # No install requested, exit silently
    exit 0
fi

# Read marker file
APP_PATH=$(jq -r '.app_path' "$MARKER_FILE")
BUNDLE_ID=$(jq -r '.bundle_id' "$MARKER_FILE")
DEVICE_TYPE=$(jq -r '.device_type' "$MARKER_FILE")
DEVICE_UDID=$(jq -r '.device_udid' "$MARKER_FILE")
DEVICE_NAME=$(jq -r '.device_name' "$MARKER_FILE")

# Clean up marker file
rm -f "$MARKER_FILE"

# Validate
if [ -z "$APP_PATH" ] || [ "$APP_PATH" = "null" ]; then
    exit 0
fi

if [ ! -d "$APP_PATH" ]; then
    echo "⚠️  App not found: $APP_PATH"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Auto-deploying to $DEVICE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 App: $(basename "$APP_PATH")"
echo "🔖 Bundle: $BUNDLE_ID"

# ============================================================
# BOOT SIMULATOR (if needed)
# ============================================================

if [ "$DEVICE_TYPE" = "simulator" ]; then
    SIM_STATE=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.udid == \"$DEVICE_UDID\") | .state" 2>/dev/null)

    if [ "$SIM_STATE" != "Booted" ]; then
        echo ""
        echo "🚀 Booting simulator..."
        xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
        sleep 1
    fi

    # Open Simulator.app
    open -a Simulator
fi

# ============================================================
# INSTALL APP
# ============================================================

echo ""
echo "📲 Installing..."

if [ "$DEVICE_TYPE" = "simulator" ]; then
    if xcrun simctl install "$DEVICE_UDID" "$APP_PATH" 2>&1; then
        echo "✅ Installed"
    else
        echo "❌ Install failed"
        exit 1
    fi
else
    # Real device
    if xcrun devicectl device install app -d "$DEVICE_UDID" "$APP_PATH" 2>/dev/null; then
        echo "✅ Installed"
    elif command -v ios-deploy &> /dev/null; then
        ios-deploy --id "$DEVICE_UDID" --bundle "$APP_PATH" && echo "✅ Installed"
    else
        echo "❌ Install failed (try: brew install ios-deploy)"
        exit 1
    fi
fi

# ============================================================
# LAUNCH APP
# ============================================================

echo ""
echo "🎬 Launching..."

if [ "$DEVICE_TYPE" = "simulator" ]; then
    # Terminate existing instance
    xcrun simctl terminate "$DEVICE_UDID" "$BUNDLE_ID" 2>/dev/null || true

    # Launch
    if xcrun simctl launch "$DEVICE_UDID" "$BUNDLE_ID" 2>&1; then
        echo "✅ Launched"
    else
        echo "❌ Launch failed"
        exit 1
    fi
else
    # Real device
    if xcrun devicectl device process launch -d "$DEVICE_UDID" "$BUNDLE_ID" 2>/dev/null; then
        echo "✅ Launched"
    elif command -v ios-deploy &> /dev/null; then
        ios-deploy --id "$DEVICE_UDID" --bundle-id "$BUNDLE_ID" --justlaunch && echo "✅ Launched"
    else
        echo "❌ Launch failed"
        exit 1
    fi
fi

echo ""
echo "🎉 App running on $DEVICE_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
