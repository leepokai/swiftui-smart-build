# Preferences Setup Flow

Run this setup when `preferences.json` doesn't exist or when user requests `/simulator-build-boot-install revise`.

## Step 1: List Available Options

```bash
# List schemes
xcodebuild -list -json 2>/dev/null | jq -r '.project.schemes[]'

# List iOS versions
xcrun simctl list runtimes available -j | jq -r '.runtimes[] | select(.platform == "iOS") | .name'
```

## Step 2: Ask User to Choose Scheme & iOS Version

Use **AskUserQuestion** tool to ask:
1. Which scheme to use for simulator builds?
2. Which iOS version to target?

## Step 3: List Simulators for Chosen iOS Version

```bash
# Convert iOS version to runtime key (e.g., "iOS 26.2" → "iOS-26-2")
RUNTIME_KEY="com.apple.CoreSimulator.SimRuntime.iOS-26-2"
xcrun simctl list devices available -j | jq -r '.devices["'$RUNTIME_KEY'"][] | select(.isAvailable) | .name' | sort -u
```

## Step 4: Ask User to Choose Simulator

Use **AskUserQuestion** tool to ask which device.

## Step 5: Lookup UDID and Save

```bash
# Get UDID for device + iOS version
xcrun simctl list devices available -j | jq -r '.devices["'$RUNTIME_KEY'"][] | select(.name == "DEVICE_NAME" and .isAvailable) | .udid' | head -1
```

Save to `$CLAUDE_PLUGIN_ROOT/preferences.json`:

```json
{
  "simulator": {
    "scheme": "App-DebugLocal",
    "device": "iPhone 16e",
    "ios_version": "iOS 26.2",
    "udid": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  },
  "device": {
    "scheme": "App-DebugRemote"
  }
}
```

## Step 6: Show Summary

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Simulator Build Settings Saved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scheme:      App-DebugLocal
iOS Version: iOS 26.2
Device:      iPhone 16e
UDID:        XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
