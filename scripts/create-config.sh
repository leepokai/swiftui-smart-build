#!/bin/bash
# Create .smart-build.json configuration file
# Usage:
#   create-config.sh xcode                     # Xcode sync mode
#   create-config.sh custom <scheme> <dest>    # Custom mode with destination JSON

MODE="$1"

if [ -z "$MODE" ]; then
    echo "Usage:"
    echo "  create-config.sh xcode"
    echo "  create-config.sh custom <scheme> <destination_json>"
    echo ""
    echo "Examples:"
    echo "  create-config.sh xcode"
    echo "  create-config.sh custom MyApp '{\"type\":\"simulator\",\"name\":\"iPhone 16 Pro\",\"udid\":\"ABC123\",\"platform\":\"iphonesimulator\"}'"
    exit 1
fi

if [ "$MODE" = "xcode" ]; then
    # Xcode sync mode - simple config
    cat > .smart-build.json << 'EOF'
{
  "mode": "xcode"
}
EOF
    echo "✅ Created .smart-build.json (Xcode sync mode)"

elif [ "$MODE" = "custom" ]; then
    SCHEME="$2"
    DEST_JSON="$3"

    if [ -z "$SCHEME" ] || [ -z "$DEST_JSON" ]; then
        echo "ERROR: Custom mode requires scheme and destination"
        echo "Usage: create-config.sh custom <scheme> <destination_json>"
        exit 1
    fi

    # Create custom config
    cat > .smart-build.json << EOF
{
  "mode": "custom",
  "scheme": "$SCHEME",
  "destination": $DEST_JSON
}
EOF
    echo "✅ Created .smart-build.json (Custom mode: $SCHEME)"

else
    echo "ERROR: Unknown mode '$MODE'. Use 'xcode' or 'custom'."
    exit 1
fi
