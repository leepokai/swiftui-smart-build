#!/bin/bash
# Check if current directory contains an Xcode project
# Usage: check-project.sh
# Returns JSON with project info or error

XCWORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)
XCODEPROJ=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)

if [ -n "$XCWORKSPACE" ]; then
    echo "{"
    echo "  \"found\": true,"
    echo "  \"type\": \"workspace\","
    echo "  \"path\": \"$XCWORKSPACE\""
    echo "}"
elif [ -n "$XCODEPROJ" ]; then
    echo "{"
    echo "  \"found\": true,"
    echo "  \"type\": \"project\","
    echo "  \"path\": \"$XCODEPROJ\""
    echo "}"
else
    echo "{"
    echo "  \"found\": false,"
    echo "  \"error\": \"No .xcworkspace or .xcodeproj found in current directory\""
    echo "}"
    exit 1
fi
