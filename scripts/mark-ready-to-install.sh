#!/bin/bash

# Called by Claude after successful build to mark app ready for install
# Creates a marker file with app info for the Stop hook to read

MARKER_FILE="/tmp/.claude-install-ready-${CLAUDE_SESSION_ID:-default}.json"

APP_PATH="$1"
BUNDLE_ID="$2"
DEVICE_TYPE="$3"
DEVICE_UDID="$4"
DEVICE_NAME="$5"

if [ -z "$APP_PATH" ] || [ -z "$BUNDLE_ID" ]; then
    echo "Usage: mark-ready-to-install.sh <app_path> <bundle_id> <device_type> <device_udid> <device_name>"
    exit 1
fi

# Write marker file
cat > "$MARKER_FILE" << EOF
{
  "app_path": "$APP_PATH",
  "bundle_id": "$BUNDLE_ID",
  "device_type": "$DEVICE_TYPE",
  "device_udid": "$DEVICE_UDID",
  "device_name": "$DEVICE_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "✓ Marked ready for install: $BUNDLE_ID → $DEVICE_NAME"
