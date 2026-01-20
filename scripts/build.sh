#!/bin/bash
# Build script for Smart Build plugin
# Usage: build.sh <scheme> <destination> [workspace|project path]

set -e

SCHEME="$1"
DESTINATION="$2"
PROJECT_PATH="$3"

if [ -z "$SCHEME" ] || [ -z "$DESTINATION" ]; then
    echo "Usage: build.sh <scheme> <destination> [workspace|project path]"
    echo "Example: build.sh MyApp 'platform=iOS Simulator,name=iPhone 16 Pro'"
    exit 1
fi

# Find project if not specified
if [ -z "$PROJECT_PATH" ]; then
    PROJECT_PATH=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)
    if [ -z "$PROJECT_PATH" ]; then
        PROJECT_PATH=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)
    fi
fi

if [ -z "$PROJECT_PATH" ]; then
    echo "ERROR: No .xcworkspace or .xcodeproj found"
    exit 1
fi

# Determine if workspace or project
if [[ "$PROJECT_PATH" == *.xcworkspace ]]; then
    PROJECT_FLAG="-workspace"
else
    PROJECT_FLAG="-project"
fi

echo "Building..."
echo "  Scheme: $SCHEME"
echo "  Destination: $DESTINATION"
echo "  Project: $PROJECT_PATH"
echo ""

xcodebuild \
    $PROJECT_FLAG "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -allowProvisioningUpdates \
    build

echo ""
echo "BUILD SUCCEEDED"
