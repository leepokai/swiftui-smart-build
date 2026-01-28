---
argument-hint: [revise - to change settings]
description: Build for physical iOS device and auto-install
---

# Device: Build → Install → Launch

Build for physical iOS device with saved preferences.

## Prerequisites

1. **Device connected** via USB or Wi-Fi
2. **Device trusted** on this Mac
3. **Signing configured** in Xcode (Team + Bundle ID)

## Workflow

### Step 1: Check for saved preferences

Look for preferences file at: `$CLAUDE_PLUGIN_ROOT/preferences.json`

```json
{
  "simulator": {
    "scheme": "SCHEME_NAME",
    "device": "iPhone 16e"
  },
  "device": {
    "scheme": "SCHEME_NAME"
  }
}
```

### Step 2: Handle based on argument and preferences

**If argument is "revise"** OR **no device preferences exist**:
→ Go to Step 3 (Setup/Revise flow)

**If device preferences exist and no "revise" argument**:
→ Go to Step 4 (Build with saved preferences)

### Step 3: Setup/Revise Flow (Interactive)

1. **List available schemes** from the project:
   ```bash
   xcodebuild -list -json 2>/dev/null | jq -r '.project.schemes[]'
   ```

2. **Ask user to choose a scheme** using AskUserQuestion tool
   - Note: For device builds, typically use a scheme with proper signing (e.g., "Release" or "Debug-Remote")

3. **Save preferences** to `$CLAUDE_PLUGIN_ROOT/preferences.json`:
   - Read existing file (if any) to preserve simulator preferences
   - Update device section with new choices
   - Write back to file

4. **Confirm to user** the saved preferences

5. Continue to Step 4

### Step 4: Build with saved preferences

Read preferences from `$CLAUDE_PLUGIN_ROOT/preferences.json` and run:

```bash
xcodebuild \
  -scheme "SAVED_SCHEME" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  build
```

## Example preferences.json

```json
{
  "simulator": {
    "scheme": "Signalsurf-DebugLocal",
    "device": "iPhone 16e"
  },
  "device": {
    "scheme": "Signalsurf-DebugRemote"
  }
}
```

## Check Connected Devices

```bash
xcrun devicectl list devices
```

## What Happens After Build

When build succeeds, the post-build hook automatically:
1. Detects connected device
2. Installs the app via `devicectl`
3. Launches the app

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No device found | Check USB connection, trust the Mac on device |
| Signing error | Open Xcode, configure Team in Signing & Capabilities |
| Install fails | Ensure device is unlocked, check provisioning profile |
