#!/bin/bash

# PostToolUse hook: Auto-install after successful xcodebuild
# Triggered after every Bash tool call, checks if it was a successful build

# Debug log file
LOG_DIR="/tmp/swiftui-smart-build"
mkdir -p "$LOG_DIR"
DEBUG_LOG="$LOG_DIR/post-build-install.log"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not installed. Run: brew install jq" >> "$DEBUG_LOG"
    exit 0
fi

# Read JSON input from stdin
INPUT_JSON=$(cat)

echo "========== $(date) ==========" >> "$DEBUG_LOG"
echo "INPUT_JSON: $INPUT_JSON" >> "$DEBUG_LOG"

# Parse JSON using jq
TOOL_NAME=$(echo "$INPUT_JSON" | jq -r '.tool_name // empty')
TOOL_INPUT=$(echo "$INPUT_JSON" | jq -r '.tool_input.command // empty')
TOOL_RESULT=$(echo "$INPUT_JSON" | jq -r '.tool_response.stdout // empty')

echo "TOOL_NAME: $TOOL_NAME" >> "$DEBUG_LOG"
echo "TOOL_INPUT: $TOOL_INPUT" >> "$DEBUG_LOG"
echo "TOOL_RESULT (first 500 chars): ${TOOL_RESULT:0:500}" >> "$DEBUG_LOG"

# Only process Bash tool calls
if [ "$TOOL_NAME" != "Bash" ]; then
    echo "EXIT: Not a Bash tool call (got: $TOOL_NAME)" >> "$DEBUG_LOG"
    exit 0
fi

# Check if this is an xcodebuild command
if ! echo "$TOOL_INPUT" | grep -q "xcodebuild"; then
    echo "EXIT: Not an xcodebuild command" >> "$DEBUG_LOG"
    exit 0
fi

# Check if the output contains BUILD SUCCEEDED (xcodebuild success marker)
if ! echo "$TOOL_RESULT" | grep -q "BUILD SUCCEEDED"; then
    echo "EXIT: No BUILD SUCCEEDED found in output" >> "$DEBUG_LOG"
    exit 0
fi

echo "PASSED: xcodebuild with BUILD SUCCEEDED detected!" >> "$DEBUG_LOG"

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

echo "SCHEME: $SCHEME" >> "$DEBUG_LOG"
echo "DESTINATION: $DESTINATION" >> "$DEBUG_LOG"

if [ -z "$SCHEME" ]; then
    echo "EXIT: Could not determine scheme" >> "$DEBUG_LOG"
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
# Strategy: Find the most recently modified .app matching the platform

echo "PLATFORM: $PLATFORM" >> "$DEBUG_LOG"

# Method 1: Try to find .app in Build/Products/*-$PLATFORM directory, sorted by modification time
# Exclude Index.noindex (Xcode indexing) and other non-product directories
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/*-$PLATFORM/*.app" -name "*.app" -type d 2>/dev/null | grep -v "Index.noindex" | while read app; do
    # Get modification time and path
    stat -f "%m %N" "$app" 2>/dev/null
done | sort -rn | head -1 | cut -d' ' -f2-)

echo "APP_PATH (by mtime): $APP_PATH" >> "$DEBUG_LOG"

# Method 2: If not found, try any Build/Products directory
if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/*.app" -name "*.app" -type d 2>/dev/null | grep -v "Index.noindex" | while read app; do
        stat -f "%m %N" "$app" 2>/dev/null
    done | sort -rn | head -1 | cut -d' ' -f2-)
    echo "APP_PATH (fallback): $APP_PATH" >> "$DEBUG_LOG"
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "EXIT: No .app found in DerivedData" >> "$DEBUG_LOG"
    echo "⚠️  App not found in DerivedData"
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
    # Try to extract UDID directly from destination (most precise)
    SIM_UDID_FROM_DEST=$(echo "$DESTINATION" | grep -oE 'id=[A-F0-9-]+' | sed 's/id=//' | head -1)

    # Try to extract simulator name from destination
    SIM_NAME=$(echo "$DESTINATION" | grep -oE 'name=[^,]+' | sed 's/name=//' | head -1)

    echo "SIM_UDID_FROM_DEST: $SIM_UDID_FROM_DEST" >> "$DEBUG_LOG"
    echo "SIM_NAME: $SIM_NAME" >> "$DEBUG_LOG"

    # PRIORITY 0: Use UDID from destination if specified (most precise)
    if [ -n "$SIM_UDID_FROM_DEST" ]; then
        SIM_UDID="$SIM_UDID_FROM_DEST"
        echo "Using UDID from destination: $SIM_UDID" >> "$DEBUG_LOG"
    fi

    # PRIORITY 1: Find a BOOTED simulator matching the name
    if [ -z "$SIM_UDID" ] && [ -n "$SIM_NAME" ]; then
        SIM_UDID=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.name == \"$SIM_NAME\" and .state == \"Booted\") | .udid" 2>/dev/null | head -1)
    fi

    # PRIORITY 2: Use any booted simulator
    if [ -z "$SIM_UDID" ]; then
        SIM_UDID=$(xcrun simctl list devices -j 2>/dev/null | jq -r '.devices[][] | select(.state == "Booted") | .udid' 2>/dev/null | head -1)
    fi

    # PRIORITY 3: Find available simulator matching name (will need to boot)
    if [ -z "$SIM_UDID" ] && [ -n "$SIM_NAME" ]; then
        SIM_UDID=$(xcrun simctl list devices available -j 2>/dev/null | jq -r ".devices[][] | select(.name == \"$SIM_NAME\" and .isAvailable == true) | .udid" 2>/dev/null | head -1)
    fi

    # PRIORITY 4: If still not found, use the first available iPhone
    if [ -z "$SIM_UDID" ]; then
        echo "🔍 No simulator specified, finding one..."
        SIM_INFO=$(xcrun simctl list devices available -j 2>/dev/null | jq -r '.devices[][] | select(.isAvailable == true and (.name | contains("iPhone"))) | "\(.udid) \(.name)"' 2>/dev/null | head -1)
        SIM_UDID=$(echo "$SIM_INFO" | awk '{print $1}')
        SIM_NAME=$(echo "$SIM_INFO" | cut -d' ' -f2-)

        if [ -z "$SIM_UDID" ]; then
            echo "❌ No available simulator found"
            exit 1
        fi
    fi

    echo "Target UDID: $SIM_UDID" >> "$DEBUG_LOG"

    # ============================================================
    # BOOT SIMULATOR IF NEEDED
    # ============================================================
    # Check if the target simulator is already booted
    SIM_STATE=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.udid == \"$SIM_UDID\") | .state" 2>/dev/null)
    echo "SIM_STATE: $SIM_STATE" >> "$DEBUG_LOG"

    if [ "$SIM_STATE" != "Booted" ]; then
        # Get simulator name for display
        if [ -z "$SIM_NAME" ]; then
            SIM_NAME=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.udid == \"$SIM_UDID\") | .name" 2>/dev/null)
        fi

        echo "🚀 Booting: $SIM_NAME ($SIM_UDID)"
        BOOT_OUTPUT=$(xcrun simctl boot "$SIM_UDID" 2>&1)
        BOOT_EXIT=$?

        # Check if boot succeeded or already booted
        if [ $BOOT_EXIT -ne 0 ]; then
            if echo "$BOOT_OUTPUT" | grep -q "Unable to boot device in current state: Booted"; then
                echo "✅ Already booted"
            else
                echo "❌ Failed to boot simulator: $BOOT_OUTPUT"
                echo "BOOT_OUTPUT: $BOOT_OUTPUT" >> "$DEBUG_LOG"
                exit 1
            fi
        else
            echo "✅ Booted"
        fi
        sleep 2
    else
        echo "✅ Simulator already running"
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

    # Find connected device - extract UUID using regex (handles spaces in device names)
    DEVICE_UDID=$(xcrun devicectl list devices 2>/dev/null | grep -oE "[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}" | head -1)

    if [ -z "$DEVICE_UDID" ]; then
        echo "❌ No connected device found"
        exit 1
    fi

    # Get device name from the line containing the UDID
    DEVICE_NAME=$(xcrun devicectl list devices 2>/dev/null | grep "$DEVICE_UDID" | sed 's/   .*//')
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
