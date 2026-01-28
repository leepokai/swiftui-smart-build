#!/bin/bash

# PostToolUse hook: Auto-install after successful xcodebuild
# Triggered after every Bash tool call, checks if it was a successful build

# Only process Bash tool calls
if [ "$CLAUDE_TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# Check if the output contains BUILD SUCCEEDED (xcodebuild success marker)
if ! echo "$CLAUDE_TOOL_RESULT" | grep -q "BUILD SUCCEEDED"; then
    exit 0
fi

# Extract info from the build output
TOOL_INPUT="$CLAUDE_TOOL_INPUT"
TOOL_RESULT="$CLAUDE_TOOL_RESULT"

# Try to extract scheme from xcodebuild command
SCHEME=$(echo "$TOOL_INPUT" | grep -oE '\-scheme\s+"?([^"]+)"?' | sed 's/-scheme[[:space:]]*"*\([^"]*\)"*/\1/' | head -1)
if [ -z "$SCHEME" ]; then
    SCHEME=$(echo "$TOOL_INPUT" | grep -oE '\-scheme\s+([^\s]+)' | awk '{print $2}' | head -1)
fi

# Try to extract destination
DESTINATION=$(echo "$TOOL_INPUT" | grep -oE '\-destination\s+"[^"]+"' | sed 's/-destination[[:space:]]*"\([^"]*\)"/\1/' | head -1)
if [ -z "$DESTINATION" ]; then
    DESTINATION=$(echo "$TOOL_INPUT" | grep -oE "\-destination\s+'[^']+'" | sed "s/-destination[[:space:]]*'\([^']*\)'/\1/" | head -1)
fi

if [ -z "$SCHEME" ]; then
    # Try to find from "Building..." line in build.sh output
    SCHEME=$(echo "$TOOL_RESULT" | grep -oE 'Scheme:\s+(.+)' | sed 's/Scheme:[[:space:]]*//' | head -1)
fi

if [ -z "$SCHEME" ]; then
    echo "⚠️  Could not determine scheme from build command"
    exit 0
fi

# Determine platform from destination
PLATFORM="iphonesimulator"
DEVICE_TYPE="simulator"
if echo "$DESTINATION" | grep -qi "generic/platform=iOS\|platform=iOS,\|iphoneos"; then
    PLATFORM="iphoneos"
    DEVICE_TYPE="device"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Auto-installing after successful build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Find the app in DerivedData
PRODUCT_DIR="Debug-$PLATFORM"
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/$PRODUCT_DIR/$SCHEME.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "⚠️  App not found: $SCHEME.app in $PRODUCT_DIR"
    echo "    Searched in: ~/Library/Developer/Xcode/DerivedData"
    exit 0
fi

echo "📍 Found: $(basename "$APP_PATH")"

# Get bundle ID
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null)
if [ -z "$BUNDLE_ID" ]; then
    echo "⚠️  Could not read bundle ID"
    exit 0
fi
echo "🔖 Bundle: $BUNDLE_ID"

# ============================================================
# SIMULATOR HANDLING
# ============================================================

if [ "$DEVICE_TYPE" = "simulator" ]; then
    # Try to extract simulator name from destination
    SIM_NAME=$(echo "$DESTINATION" | grep -oE 'name=[^,]+' | sed 's/name=//' | head -1)

    # Find simulator UDID
    if [ -n "$SIM_NAME" ]; then
        SIM_UDID=$(xcrun simctl list devices available -j 2>/dev/null | jq -r ".devices[][] | select(.name == \"$SIM_NAME\" and .isAvailable == true) | .udid" 2>/dev/null | head -1)
    fi

    # If not found, use any booted simulator
    if [ -z "$SIM_UDID" ]; then
        SIM_UDID=$(xcrun simctl list devices booted -j 2>/dev/null | jq -r '.devices[][] | select(.state == "Booted") | .udid' 2>/dev/null | head -1)
    fi

    # If still not found, boot the first available iPhone
    if [ -z "$SIM_UDID" ]; then
        echo "🔍 No booted simulator, finding one to boot..."
        SIM_INFO=$(xcrun simctl list devices available -j 2>/dev/null | jq -r '.devices[][] | select(.isAvailable == true and (.name | contains("iPhone"))) | "\(.udid) \(.name)"' 2>/dev/null | head -1)
        SIM_UDID=$(echo "$SIM_INFO" | awk '{print $1}')
        SIM_NAME=$(echo "$SIM_INFO" | cut -d' ' -f2-)

        if [ -z "$SIM_UDID" ]; then
            echo "❌ No available simulator found"
            exit 1
        fi

        echo "🚀 Booting: $SIM_NAME"
        xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
        sleep 2
    fi

    # Open Simulator app
    open -a Simulator
    sleep 1

    # Get device name for display
    if [ -z "$SIM_NAME" ]; then
        SIM_NAME=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.udid == \"$SIM_UDID\") | .name" 2>/dev/null)
    fi

    echo "📱 Target: $SIM_NAME"
    echo ""
    echo "📲 Installing..."

    if xcrun simctl install "$SIM_UDID" "$APP_PATH" 2>&1; then
        echo "✅ Installed"
    else
        echo "❌ Install failed"
        exit 1
    fi

    echo ""
    echo "🎬 Launching..."

    # Terminate existing instance
    xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" 2>/dev/null || true

    if xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" 2>&1; then
        echo "✅ Launched"
    else
        echo "❌ Launch failed"
        exit 1
    fi

    echo ""
    echo "🎉 App running on $SIM_NAME"

# ============================================================
# REAL DEVICE HANDLING
# ============================================================

else
    echo "📱 Target: Physical device"

    # Find connected device
    DEVICE_INFO=$(xcrun devicectl list devices 2>/dev/null | grep -E "^[A-F0-9-]{36}" | head -1)
    DEVICE_UDID=$(echo "$DEVICE_INFO" | awk '{print $1}')

    if [ -z "$DEVICE_UDID" ]; then
        echo "❌ No connected device found"
        exit 1
    fi

    DEVICE_NAME=$(xcrun devicectl list devices 2>/dev/null | grep "$DEVICE_UDID" | awk '{$1=""; print $0}' | xargs)
    echo "📱 Device: $DEVICE_NAME"

    echo ""
    echo "📲 Installing..."

    if xcrun devicectl device install app -d "$DEVICE_UDID" "$APP_PATH" 2>&1; then
        echo "✅ Installed"
    elif command -v ios-deploy &> /dev/null; then
        if ios-deploy --id "$DEVICE_UDID" --bundle "$APP_PATH" 2>&1; then
            echo "✅ Installed"
        else
            echo "❌ Install failed"
            exit 1
        fi
    else
        echo "❌ Install failed (try: brew install ios-deploy)"
        exit 1
    fi

    echo ""
    echo "🎬 Launching..."

    if xcrun devicectl device process launch -d "$DEVICE_UDID" "$BUNDLE_ID" 2>&1; then
        echo "✅ Launched"
    elif command -v ios-deploy &> /dev/null; then
        ios-deploy --id "$DEVICE_UDID" --bundle-id "$BUNDLE_ID" --justlaunch 2>&1 && echo "✅ Launched"
    else
        echo "⚠️  Could not launch (try manually)"
    fi

    echo ""
    echo "🎉 App installed on $DEVICE_NAME"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
