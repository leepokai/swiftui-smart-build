---
name: settings
description: This skill should be used when the user asks to "show settings", "change build settings", "switch to xcode mode", "change destination", "view config", or uses the /settings command. View or modify Smart Build configuration.
---

# Smart Build Settings

View and modify Smart Build configuration.

## When to Use

- User asks to see current settings
- User wants to change scheme or destination
- User wants to switch between Xcode sync and custom mode
- User says "change build settings", "switch to simulator", "build to my phone", etc.

## Show Current Settings

### Step 1: Read config

```bash
cat .smart-build.json 2>/dev/null
```

### Step 2: If Xcode mode, also show current Xcode settings

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
```

### Step 3: Display to user

```
Current Smart Build Settings:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode: Xcode Sync

Current Xcode configuration:
  Scheme: SmartBuildTest
  Destination: iPhone 16 Pro (Simulator)

Your builds will automatically use whatever is selected in Xcode.
```

Or for custom mode:
```
Current Smart Build Settings:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Mode: Custom

Fixed configuration:
  Scheme: MyApp-Debug
  Destination: iPhone 16 (Simulator)
```

## Modify Settings

### Change Mode

If user wants to switch modes:

1. Ask for confirmation
2. If switching to custom, run the custom setup flow (ask for scheme, destination)
3. If switching to Xcode sync, just update mode
4. Save to `.smart-build.json`

### Change Destination Only (Custom Mode)

1. List available destinations:
```bash
# Simulators
xcrun simctl list devices available -j | jq -r '.devices[][] | select(.name | contains("iPhone")) | "\(.name) - \(.udid)"' | head -10

# Booted
xcrun simctl list devices booted -j | jq -r '.devices[][] | "⚡ \(.name) (Running) - \(.udid)"'

# Devices
xcrun devicectl list devices -j 2>/dev/null | jq -r '.result.devices[] | "📱 \(.deviceProperties.name) (Device) - \(.identifier)"'
```

2. Ask user to pick
3. Update `.smart-build.json`

### Change Scheme Only (Custom Mode)

1. List available schemes:
```bash
xcodebuild -project *.xcodeproj -list -json | jq -r '.project.schemes[]'
```

2. Ask user to pick
3. Update `.smart-build.json`

## Quick Commands

User might say things like:

| User Says | Action |
|-----------|--------|
| "show settings" | Display current config |
| "switch to Xcode mode" | Change mode to "xcode" |
| "use custom settings" | Change mode to "custom", ask for details |
| "change destination" | List destinations, let user pick |
| "build to real device" | Find connected device, update destination |
| "use iPhone 16" | Find that simulator, update destination |

## Config File Format

`.smart-build.json`:

```json
{
  "mode": "xcode",
  "scheme": null,
  "destination": null
}
```

Or:

```json
{
  "mode": "custom",
  "scheme": "MyApp",
  "destination": {
    "type": "simulator",
    "udid": "12345678-ABCD-1234-ABCD-123456789ABC",
    "name": "iPhone 16 Pro",
    "platform": "iphonesimulator"
  }
}
```

## Example Conversations

### View Settings
```
User: show my build settings

Claude: Current Smart Build Settings:
Mode: Xcode Sync
Scheme: SmartBuildTest
Destination: iPhone 17 Pro (Simulator)
```

### Change to Device
```
User: I want to build to my real iPhone

Claude: Let me check for connected devices...

Found:
📱 John's iPhone (Device) - 00008030-001A2B3C4D5E

Switching destination to your iPhone. Updated .smart-build.json
```
