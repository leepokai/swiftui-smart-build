---
name: smart-build
description: Build Swift/SwiftUI projects and auto-deploy to simulator or device. Use when user wants to build, run, test on simulator, or deploy to device.
---

# Smart Build Skill

Build-to-deploy system for Swift/SwiftUI projects.

## Workflow

```
┌─────────────────────────────────────────────────┐
│  During Conversation (Claude)                    │
│                                                 │
│  1. Write/modify Swift code                     │
│  2. Run xcodebuild                              │
│  3. If fails → fix code → repeat                │
│  4. If succeeds → mark ready for install        │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  On Stop (Auto Hook)                            │
│                                                 │
│  If marked ready:                               │
│    → Boot simulator (if needed)                 │
│    → Install app                                │
│    → Launch app                                 │
│  If not marked:                                 │
│    → Do nothing                                 │
└─────────────────────────────────────────────────┘
```

## How to Build

### 1. Detect Project

```bash
# Find workspace or project
find . -maxdepth 2 -name "*.xcworkspace" -o -name "*.xcodeproj"
```

### 2. Detect Scheme

```bash
xcodebuild -project MyApp.xcodeproj -list -json | jq '.project.schemes[]'
# or
xcodebuild -workspace MyApp.xcworkspace -list -json | jq '.workspace.schemes[]'
```

### 3. Detect Destination (Priority Order)

```bash
# 1. Running simulator (highest priority)
xcrun simctl list devices booted -j | jq '.devices[][] | select(.state == "Booted")'

# 2. Connected device
xcrun devicectl list devices -j | jq '.result.devices[] | select(.connectionProperties.transportType == "wired")'

# 3. Any available simulator
xcrun simctl list devices available -j | jq '.devices[][] | select(.name | contains("iPhone"))'
```

### 4. Build

```bash
xcodebuild \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination "platform=iOS Simulator,id=<UDID>" \
  -configuration Debug \
  -allowProvisioningUpdates \
  build
```

### 5. On Success - Mark Ready for Install

```bash
# Get app path from DerivedData
APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/MyApp-xxx/Build/Products/Debug-iphonesimulator/MyApp.app"

# Get bundle ID
BUNDLE_ID=$(defaults read "$APP_PATH/Info.plist" CFBundleIdentifier)

# Mark ready (this enables auto-install on Stop)
${CLAUDE_PLUGIN_ROOT}/scripts/mark-ready-to-install.sh \
  "$APP_PATH" \
  "$BUNDLE_ID" \
  "simulator" \
  "<DEVICE_UDID>" \
  "<DEVICE_NAME>"
```

## Important

- **Always build until success** before marking ready
- **Mark ready** only after confirmed successful build
- **The user's app will auto-launch** when conversation ends (if marked)
- If user just wants to check syntax without deploying, don't mark ready

## Destination Types

| Type | Destination String | Product Dir |
|------|-------------------|-------------|
| Simulator | `platform=iOS Simulator,id=<UDID>` | `Debug-iphonesimulator` |
| Device | `platform=iOS,id=<UDID>` | `Debug-iphoneos` |

## Build Flags

- `-allowProvisioningUpdates`: Auto-sign for real devices
- `-configuration Debug`: Use Debug config
- `-quiet`: Less verbose output (optional)
