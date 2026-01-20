#!/bin/bash
# List available destinations (simulators and devices)
# Usage: list-destinations.sh [type]
#   type: all (default), simulators, devices, booted

TYPE="${1:-all}"

echo "{"
echo "  \"booted_simulators\": ["

# Booted simulators (highest priority)
BOOTED=$(xcrun simctl list devices booted -j 2>/dev/null | jq -r '.devices[][] | @json' 2>/dev/null)
FIRST=true
while IFS= read -r line; do
    if [ -n "$line" ]; then
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo ","
        fi
        NAME=$(echo "$line" | jq -r '.name')
        UDID=$(echo "$line" | jq -r '.udid')
        echo -n "    {\"name\": \"$NAME\", \"udid\": \"$UDID\", \"type\": \"simulator\", \"platform\": \"iphonesimulator\", \"status\": \"booted\"}"
    fi
done <<< "$BOOTED"

echo ""
echo "  ],"

if [ "$TYPE" = "all" ] || [ "$TYPE" = "simulators" ]; then
    echo "  \"available_simulators\": ["

    # Available iPhone simulators
    AVAILABLE=$(xcrun simctl list devices available -j 2>/dev/null | jq -r '.devices[][] | select(.isAvailable==true) | select(.name | contains("iPhone")) | @json' 2>/dev/null | head -10)
    FIRST=true
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo ","
            fi
            NAME=$(echo "$line" | jq -r '.name')
            UDID=$(echo "$line" | jq -r '.udid')
            echo -n "    {\"name\": \"$NAME\", \"udid\": \"$UDID\", \"type\": \"simulator\", \"platform\": \"iphonesimulator\"}"
        fi
    done <<< "$AVAILABLE"

    echo ""
    echo "  ],"
fi

if [ "$TYPE" = "all" ] || [ "$TYPE" = "devices" ]; then
    echo "  \"connected_devices\": ["

    # Connected physical devices (iOS 17+)
    DEVICES=$(xcrun devicectl list devices -j 2>/dev/null | jq -r '.result.devices[] | @json' 2>/dev/null)
    FIRST=true
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo ","
            fi
            NAME=$(echo "$line" | jq -r '.deviceProperties.name')
            UDID=$(echo "$line" | jq -r '.identifier')
            echo -n "    {\"name\": \"$NAME\", \"udid\": \"$UDID\", \"type\": \"device\", \"platform\": \"iphoneos\"}"
        fi
    done <<< "$DEVICES"

    echo ""
    echo "  ]"
else
    # Remove trailing comma if devices section is skipped
    echo "  \"connected_devices\": []"
fi

echo "}"
