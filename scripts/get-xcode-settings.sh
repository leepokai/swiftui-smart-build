#!/bin/bash

# Get current Xcode scheme and destination from xcuserstate
# Usage: get-xcode-settings.sh [project_dir]
# Output: JSON with scheme, destination info

PROJECT_DIR="${1:-.}"

# Find .xcodeproj or .xcworkspace
find_project() {
    local xcworkspace=$(find "$PROJECT_DIR" -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" 2>/dev/null | head -1)
    local xcodeproj=$(find "$PROJECT_DIR" -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" 2>/dev/null | head -1)

    if [ -n "$xcworkspace" ]; then
        echo "$xcworkspace"
    elif [ -n "$xcodeproj" ]; then
        echo "$xcodeproj"
    fi
}

# Find UserInterfaceState.xcuserstate
find_userstate() {
    local project_path="$1"
    local username=$(whoami)

    # Check in xcworkspace first
    if [[ "$project_path" == *.xcworkspace ]]; then
        local userstate="$project_path/xcuserdata/$username.xcuserdatad/UserInterfaceState.xcuserstate"
        if [ -f "$userstate" ]; then
            echo "$userstate"
            return
        fi
    fi

    # Check in xcodeproj
    if [[ "$project_path" == *.xcodeproj ]]; then
        # First try project.xcworkspace inside xcodeproj
        local userstate="$project_path/project.xcworkspace/xcuserdata/$username.xcuserdatad/UserInterfaceState.xcuserstate"
        if [ -f "$userstate" ]; then
            echo "$userstate"
            return
        fi
        # Try xcuserdata directly in xcodeproj
        userstate="$project_path/xcuserdata/$username.xcuserdatad/UserInterfaceState.xcuserstate"
        if [ -f "$userstate" ]; then
            echo "$userstate"
            return
        fi
    fi
}

# Parse xcuserstate for scheme and destination
parse_userstate() {
    local userstate="$1"

    # Convert binary plist to text and extract info
    local plist_content=$(plutil -p "$userstate" 2>/dev/null)

    # Extract scheme name (look for patterns)
    local scheme=$(echo "$plist_content" | grep -E '^\s+[0-9]+ => "[A-Za-z0-9_-]+"$' | grep -v "file:" | grep -v "/" | tail -20 | head -1 | sed 's/.*=> "\(.*\)"/\1/')

    # Better approach: find scheme from RunContextRecents
    scheme=$(echo "$plist_content" | grep -A1 "IDERunContextRecentsSchemesKey" | grep "=>" | head -1 | sed 's/.*=> "\(.*\)"/\1/' 2>/dev/null)

    if [ -z "$scheme" ]; then
        # Fallback: look for scheme pattern
        scheme=$(echo "$plist_content" | grep -oE '"[A-Za-z][A-Za-z0-9_-]*"' | tr -d '"' | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    fi

    # Extract simulator UUID
    local sim_uuid=$(echo "$plist_content" | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' | head -1)

    # Extract platform
    local platform="iphonesimulator"
    if echo "$plist_content" | grep -q "iphoneos[^i]"; then
        platform="iphoneos"
    fi

    # Get device name from simctl
    local device_name=""
    local device_type="simulator"

    if [ -n "$sim_uuid" ]; then
        device_name=$(xcrun simctl list devices -j 2>/dev/null | jq -r ".devices[][] | select(.udid == \"$sim_uuid\") | .name" 2>/dev/null)

        if [ -z "$device_name" ] || [ "$device_name" = "null" ]; then
            # Try real device
            device_name=$(xcrun devicectl list devices -j 2>/dev/null | jq -r ".result.devices[] | select(.identifier == \"$sim_uuid\") | .deviceProperties.name" 2>/dev/null)
            if [ -n "$device_name" ] && [ "$device_name" != "null" ]; then
                device_type="device"
                platform="iphoneos"
            fi
        fi
    fi

    # Output JSON
    cat << EOF
{
  "scheme": "$scheme",
  "destination": {
    "type": "$device_type",
    "udid": "$sim_uuid",
    "name": "$device_name",
    "platform": "$platform"
  }
}
EOF
}

# Main
PROJECT_PATH=$(find_project)

if [ -z "$PROJECT_PATH" ]; then
    echo '{"error": "No Xcode project found"}' >&2
    exit 1
fi

USERSTATE=$(find_userstate "$PROJECT_PATH")

if [ -z "$USERSTATE" ] || [ ! -f "$USERSTATE" ]; then
    echo '{"error": "No UserInterfaceState.xcuserstate found. Open the project in Xcode first."}' >&2
    exit 1
fi

parse_userstate "$USERSTATE"
