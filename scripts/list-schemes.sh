#!/bin/bash
# List available schemes from Xcode project/workspace
# Usage: list-schemes.sh

# Find project or workspace
XCWORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)
XCODEPROJ=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)

if [ -n "$XCWORKSPACE" ]; then
    PROJECT_FLAG="-workspace"
    PROJECT_PATH="$XCWORKSPACE"
elif [ -n "$XCODEPROJ" ]; then
    PROJECT_FLAG="-project"
    PROJECT_PATH="$XCODEPROJ"
else
    echo "ERROR: No .xcworkspace or .xcodeproj found"
    exit 1
fi

# Get schemes as JSON
SCHEMES_JSON=$(xcodebuild $PROJECT_FLAG "$PROJECT_PATH" -list -json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to list schemes"
    exit 1
fi

# Extract scheme names
if [ -n "$XCWORKSPACE" ]; then
    echo "$SCHEMES_JSON" | jq -r '.workspace.schemes[]' 2>/dev/null
else
    echo "$SCHEMES_JSON" | jq -r '.project.schemes[]' 2>/dev/null
fi
