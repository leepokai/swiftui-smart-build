#!/bin/bash

# PostToolUse hook: Validate preferences.json after Edit/Write
# Ensures AI doesn't write invalid JSON structure

LOG_DIR="/tmp/swiftui-smart-build"
mkdir -p "$LOG_DIR"
DEBUG_LOG="$LOG_DIR/validate-preferences.log"

# Read JSON input from stdin
INPUT_JSON=$(cat)

# Parse JSON
TOOL_NAME=$(echo "$INPUT_JSON" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty')

# Only process Edit or Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
    exit 0
fi

# Only process preferences.json in plugin root
if [[ "$FILE_PATH" != */swiftui-smart-build/preferences.json ]]; then
    exit 0
fi

echo "========== $(date) ==========" >> "$DEBUG_LOG"
echo "Validating: $FILE_PATH" >> "$DEBUG_LOG"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File not found, skipping validation" >> "$DEBUG_LOG"
    exit 0
fi

ERRORS=""

# ============================================================
# 1. Validate JSON syntax
# ============================================================
if ! jq empty "$FILE_PATH" 2>/dev/null; then
    ERRORS="❌ Invalid JSON syntax in preferences.json"
    echo "$ERRORS" >> "$DEBUG_LOG"

    # Output error to Claude
    ESCAPED_ERRORS=$(echo "$ERRORS" | jq -Rs .)
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ESCAPED_ERRORS
  }
}
EOF
    exit 0
fi

# ============================================================
# 2. Validate structure
# ============================================================
CONTENT=$(cat "$FILE_PATH")

# Check simulator section
SIM_SCHEME=$(echo "$CONTENT" | jq -r '.simulator.scheme // empty')
SIM_DEVICE=$(echo "$CONTENT" | jq -r '.simulator.device // empty')

# Check device section
DEV_SCHEME=$(echo "$CONTENT" | jq -r '.device.scheme // empty')

# Validate simulator section if it exists
if echo "$CONTENT" | jq -e '.simulator' > /dev/null 2>&1; then
    SIM_IOS_VERSION=$(echo "$CONTENT" | jq -r '.simulator.ios_version // empty')
    SIM_UDID=$(echo "$CONTENT" | jq -r '.simulator.udid // empty')

    if [ -z "$SIM_SCHEME" ]; then
        ERRORS="$ERRORS\n❌ Missing 'simulator.scheme' in preferences.json"
    fi
    if [ -z "$SIM_DEVICE" ]; then
        ERRORS="$ERRORS\n❌ Missing 'simulator.device' in preferences.json"
    fi
    if [ -z "$SIM_IOS_VERSION" ]; then
        ERRORS="$ERRORS\n❌ Missing 'simulator.ios_version' in preferences.json"
    fi

    # Type check - must be strings
    SIM_SCHEME_TYPE=$(echo "$CONTENT" | jq -r '.simulator.scheme | type')
    SIM_DEVICE_TYPE=$(echo "$CONTENT" | jq -r '.simulator.device | type')
    SIM_IOS_VERSION_TYPE=$(echo "$CONTENT" | jq -r '.simulator.ios_version | type')
    SIM_UDID_TYPE=$(echo "$CONTENT" | jq -r '.simulator.udid | type')

    if [ "$SIM_SCHEME_TYPE" != "string" ] && [ "$SIM_SCHEME_TYPE" != "null" ]; then
        ERRORS="$ERRORS\n❌ 'simulator.scheme' must be a string, got $SIM_SCHEME_TYPE"
    fi
    if [ "$SIM_DEVICE_TYPE" != "string" ] && [ "$SIM_DEVICE_TYPE" != "null" ]; then
        ERRORS="$ERRORS\n❌ 'simulator.device' must be a string, got $SIM_DEVICE_TYPE"
    fi
    if [ "$SIM_IOS_VERSION_TYPE" != "string" ] && [ "$SIM_IOS_VERSION_TYPE" != "null" ]; then
        ERRORS="$ERRORS\n❌ 'simulator.ios_version' must be a string, got $SIM_IOS_VERSION_TYPE"
    fi
    # UDID is optional but if present must be a string with valid UUID format
    if [ "$SIM_UDID_TYPE" != "string" ] && [ "$SIM_UDID_TYPE" != "null" ]; then
        ERRORS="$ERRORS\n❌ 'simulator.udid' must be a string, got $SIM_UDID_TYPE"
    elif [ -n "$SIM_UDID" ] && ! echo "$SIM_UDID" | grep -qE '^[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}$'; then
        ERRORS="$ERRORS\n❌ 'simulator.udid' has invalid format (expected UUID like XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX)"
    fi
fi

# Validate device section if it exists
if echo "$CONTENT" | jq -e '.device' > /dev/null 2>&1; then
    if [ -z "$DEV_SCHEME" ]; then
        ERRORS="$ERRORS\n❌ Missing 'device.scheme' in preferences.json"
    fi

    # Type check
    DEV_SCHEME_TYPE=$(echo "$CONTENT" | jq -r '.device.scheme | type')

    if [ "$DEV_SCHEME_TYPE" != "string" ] && [ "$DEV_SCHEME_TYPE" != "null" ]; then
        ERRORS="$ERRORS\n❌ 'device.scheme' must be a string, got $DEV_SCHEME_TYPE"
    fi
fi

# ============================================================
# 3. Output results
# ============================================================
if [ -n "$ERRORS" ]; then
    echo -e "$ERRORS" >> "$DEBUG_LOG"

    OUTPUT="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  preferences.json validation errors:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$(echo -e "$ERRORS")

Expected structure:
{
  \"simulator\": {
    \"scheme\": \"string\",
    \"device\": \"string\",
    \"ios_version\": \"string\",
    \"udid\": \"string (optional, UUID format)\"
  },
  \"device\": {
    \"scheme\": \"string\"
  }
}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    ESCAPED_OUTPUT=$(echo "$OUTPUT" | jq -Rs .)
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": $ESCAPED_OUTPUT
  }
}
EOF
else
    echo "✅ preferences.json is valid" >> "$DEBUG_LOG"
fi

exit 0
