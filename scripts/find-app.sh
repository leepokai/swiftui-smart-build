#!/bin/bash
# Find the built .app and get its info
# Usage: find-app.sh <scheme> <platform>
# platform: iphonesimulator or iphoneos

SCHEME="$1"
PLATFORM="${2:-iphonesimulator}"

if [ -z "$SCHEME" ]; then
    echo "Usage: find-app.sh <scheme> [platform]"
    echo "Example: find-app.sh MyApp iphonesimulator"
    exit 1
fi

PRODUCT_DIR="Debug-$PLATFORM"

# Find the app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/$PRODUCT_DIR/$SCHEME.app" -type d 2>/dev/null | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "ERROR: App not found for scheme '$SCHEME' in $PRODUCT_DIR"
    exit 1
fi

# Get bundle ID
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null)

if [ -z "$BUNDLE_ID" ]; then
    echo "ERROR: Could not read bundle ID from $APP_PATH"
    exit 1
fi

# Output as JSON
cat << EOF
{
  "app_path": "$APP_PATH",
  "bundle_id": "$BUNDLE_ID",
  "scheme": "$SCHEME",
  "platform": "$PLATFORM"
}
EOF
