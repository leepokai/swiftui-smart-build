# Preferences Setup Flow

Run this setup when `.smart-build.json` is not found in the project root or when user requests to revise preferences.

**Two modes:**
- **Simulator** — needs scheme, iOS version, device, UDID
- **Device** — only needs scheme (skip Steps 2–4)

## Step 1: List Schemes & Ask User to Choose

```bash
xcodebuild -list -json 2>/dev/null | jq -r '.project.schemes[]'
```

Use **AskUserQuestion** tool to ask which scheme to use.

> **Device setup**: after choosing scheme, skip to Step 5 (Save).

## Step 2: List iOS Versions & Ask User to Choose (Simulator Only)

```bash
xcrun simctl list runtimes available -j | jq -r '.runtimes[] | select(.platform == "iOS") | .name'
```

Use **AskUserQuestion** tool to ask which iOS version to target.

## Step 3: List Simulators for Chosen iOS Version (Simulator Only)

Use the iOS version chosen in Step 2:

```bash
xcrun simctl list devices "<CHOSEN_IOS_VERSION>" available
# e.g., xcrun simctl list devices "iOS 26.2" available
```

## Step 4: Ask User to Choose Simulator (Simulator Only)

Use **AskUserQuestion** tool to ask which device. Parse the chosen device's UDID from the Step 3 output.

## Step 5: Save Preferences

Save to `.smart-build.json` in the project root directory, filling in user's choices from previous steps:

**Simulator** saves to `simulator` section, **Device** saves to `device` section. Preserve existing sections when updating.

```json
{
  "simulator": {
    "scheme": "<CHOSEN_SCHEME>",
    "device": "<CHOSEN_DEVICE>",
    "ios_version": "<CHOSEN_IOS_VERSION>",
    "udid": "<DEVICE_UDID>"
  },
  "device": {
    "scheme": "<CHOSEN_SCHEME>"
  }
}
```

```
# e.g., simulator: scheme "App-DebugLocal", iOS "iOS 26.2", device "iPhone 16e"
# e.g., device: scheme "App-DebugRemote"
```

## Step 6: Show Summary

Display the saved preferences to the user:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Build Settings Saved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scheme:      <CHOSEN_SCHEME>
iOS Version: <CHOSEN_IOS_VERSION>        ← simulator only
Device:      <CHOSEN_DEVICE>             ← simulator only
UDID:        <DEVICE_UDID>               ← simulator only
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# e.g., simulator:
# Scheme:      App-DebugLocal
# iOS Version: iOS 26.2
# Device:      iPhone 16e
# UDID:        XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

# e.g., device:
# Scheme:      App-DebugRemote
```
