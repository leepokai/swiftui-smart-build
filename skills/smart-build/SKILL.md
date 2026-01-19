---
name: smart-build
description: Build Swift/SwiftUI projects and auto-deploy. Reads settings from .smart-build.json or prompts for setup. Use when user wants to build, run, test, or deploy.
---

# Smart Build

Build and deploy Swift/SwiftUI projects using saved settings.

## Workflow Overview

```
┌─────────────────────────────────────────────────┐
│  1. Check for .smart-build.json                 │
│     - If not exists → run setup flow            │
│     - If exists → read settings                 │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  2. Get scheme and destination                  │
│     - Xcode mode → read from xcuserstate        │
│     - Custom mode → use saved values            │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  3. Build with xcodebuild                       │
│     - If fails → fix and retry                  │
│     - If succeeds → continue                    │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  4. Mark ready for install                      │
│     - Call mark-ready-to-install.sh             │
│     - Stop hook will auto-install on exit       │
└─────────────────────────────────────────────────┘
```

## Step 0: Verify Project Directory

⚠️ **ALWAYS check this first**:

```bash
ls *.xcodeproj 2>/dev/null || ls *.xcworkspace 2>/dev/null
```

**If no project found**: STOP and tell user:
"⚠️ No Xcode project found. Please run Claude from your project folder."

## Step 1: Check Config

```bash
cat .smart-build.json 2>/dev/null
```

**If no config exists**:
- Tell user: "Smart Build isn't configured yet. Let me set it up."
- Use AskUserQuestion: "Use Xcode settings or custom?"
- Create `.smart-build.json`

**If config exists**: Read and continue.

## Step 2: Get Build Settings

### Xcode Mode (`"mode": "xcode"`)

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
```

This returns:
```json
{
  "scheme": "SmartBuildTest",
  "destination": {
    "type": "simulator",
    "udid": "12345678-...",
    "name": "iPhone 16 Pro",
    "platform": "iphonesimulator"
  }
}
```

### Custom Mode (`"mode": "custom"`)

Use values directly from `.smart-build.json`.

## Step 3: Build

```bash
# Find project
XCODEPROJ=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)
XCWORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)

# Build (use workspace if exists, otherwise project)
if [ -n "$XCWORKSPACE" ]; then
    xcodebuild -workspace "$XCWORKSPACE" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$UDID" \
        -configuration Debug \
        -allowProvisioningUpdates \
        build
else
    xcodebuild -project "$XCODEPROJ" \
        -scheme "$SCHEME" \
        -destination "platform=iOS Simulator,id=$UDID" \
        -configuration Debug \
        -allowProvisioningUpdates \
        build
fi
```

**If build fails**: Fix the code and try again.

**If build succeeds**: Continue to step 4.

## Step 4: Mark Ready for Install

After successful build:

```bash
# Find the .app
PRODUCT_DIR="Debug-iphonesimulator"  # or Debug-iphoneos for device
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/$PRODUCT_DIR/$SCHEME.app" -type d 2>/dev/null | head -1)

# Get bundle ID
BUNDLE_ID=$(defaults read "$APP_PATH/Info.plist" CFBundleIdentifier)

# Mark ready (enables auto-install when conversation ends)
${CLAUDE_PLUGIN_ROOT}/scripts/mark-ready-to-install.sh \
    "$APP_PATH" \
    "$BUNDLE_ID" \
    "$DEVICE_TYPE" \
    "$DEVICE_UDID" \
    "$DEVICE_NAME"
```

## Destination Formats

| Type | Destination String | Product Dir |
|------|-------------------|-------------|
| Simulator | `platform=iOS Simulator,id=<UDID>` | `Debug-iphonesimulator` |
| Device | `platform=iOS,id=<UDID>` | `Debug-iphoneos` |

## Important Notes

- **Always check config first** - Don't build without knowing settings
- **Xcode mode is dynamic** - Settings change when user changes Xcode selection
- **Custom mode is fixed** - Same settings every time until user changes
- **Mark ready only on success** - Never mark if build failed
- **Auto-install happens on Stop** - User's app launches when conversation ends

## Example Flow

```
User: Build and run this app

Claude: [Reads .smart-build.json - mode is "xcode"]
Claude: [Runs get-xcode-settings.sh]
Claude: Building with Xcode settings:
        Scheme: SmartBuildTest
        Destination: iPhone 16 Pro

Claude: [Runs xcodebuild...]
Claude: ✅ Build succeeded!
Claude: [Runs mark-ready-to-install.sh]
Claude: App is ready. It will auto-launch when you end this conversation.

[User ends conversation]
[Stop hook runs auto-install.sh]
[App launches on iPhone 16 Pro simulator]
```
