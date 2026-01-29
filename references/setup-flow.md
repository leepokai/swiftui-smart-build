# Preferences Setup Flow

Run this setup when `preferences.json` is not found or when user requests to revise preferences.

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

Use the iOS version chosen by user in Step 2:

```bash
xcrun simctl list devices "<CHOSEN_IOS_VERSION>" available
# e.g., xcrun simctl list devices "iOS 26.2" available
```

## Step 4: Ask User to Choose Simulator & Save

Use **AskUserQuestion** tool to ask which device. Parse the chosen device's UDID from the Step 3 output.

Save to `$CLAUDE_PLUGIN_ROOT/preferences.json`, filling in user's choices from previous steps:

```
# e.g., user chose scheme "App-DebugLocal", iOS version "iOS 26.2", device "iPhone 16e"
```

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

## Step 5: Show Summary

Display the saved preferences to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Simulator Build Settings Saved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scheme:      <CHOSEN_SCHEME>
iOS Version: <CHOSEN_IOS_VERSION>
Device:      <CHOSEN_DEVICE>
UDID:        <DEVICE_UDID>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# e.g.,
# Scheme:      App-DebugLocal
# iOS Version: iOS 26.2
# Device:      iPhone 16e
# UDID:        XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```
