---
argument-hint: [revise - to change settings]
description: Build for iOS Simulator and auto-install
---

# Simulator: Build → Boot → Install

Build for iOS Simulator with saved preferences.

## Workflow

### Step 1: Check for saved preferences

Look for preferences file at: `$CLAUDE_PLUGIN_ROOT/preferences.json`

```json
{
  "simulator": {
    "scheme": "SCHEME_NAME",
    "device": "iPhone 16e",
    "ios_version": "iOS 26.2",
    "udid": "SIMULATOR_UDID"
  },
  "device": {
    "scheme": "SCHEME_NAME"
  }
}
```

### Step 2: Handle based on argument and preferences

**If argument is "revise"** OR **no simulator preferences exist**:
→ Go to Step 3 (Setup/Revise flow)

**If simulator preferences exist and no "revise" argument**:
→ Go to Step 5 (Build with saved preferences)

### Step 3: Setup/Revise Flow (Interactive)

1. **List available schemes** from the project:
   ```bash
   xcodebuild -list -json 2>/dev/null | jq -r '.project.schemes[]'
   ```

2. **Ask user to choose a scheme** using AskUserQuestion tool

3. **List available iOS versions**:
   ```bash
   xcrun simctl list runtimes available -j | jq -r '.runtimes[] | select(.platform == "iOS") | .name'
   ```

4. **Ask user to choose iOS version** using AskUserQuestion tool

5. **List available simulators for that iOS version**:
   ```bash
   xcrun simctl list devices available -j | jq -r '.devices["com.apple.CoreSimulator.SimRuntime.iOS-26-2"] | .[] | select(.isAvailable) | .name' | sort -u
   ```
   Note: Convert iOS version to runtime key (e.g., "iOS 26.2" → "com.apple.CoreSimulator.SimRuntime.iOS-26-2")

6. **Ask user to choose a simulator device** using AskUserQuestion tool

7. Continue to Step 4 (Validation)

### Step 4: Validation & Save

1. **Validate selections** before saving:
   - Scheme exists in project
   - iOS version is available
   - Device exists for that iOS version

2. **Lookup UDID** for the selected device + iOS version:
   ```bash
   # Convert iOS version to runtime key (e.g., "iOS 26.2" → "iOS-26-2")
   RUNTIME_KEY="com.apple.CoreSimulator.SimRuntime.iOS-26-2"
   xcrun simctl list devices available -j | jq -r '.devices["'$RUNTIME_KEY'"][] | select(.name == "DEVICE_NAME" and .isAvailable) | .udid' | head -1
   ```

3. **Show summary to user**:
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   📋 Simulator Build Settings
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Scheme:      Signalsurf-DebugLocal
   iOS Version: iOS 26.2
   Device:      iPhone 16e
   UDID:        24A2580F-BABB-49D2-91EA-2B14498A4246
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

4. **Save preferences** to `$CLAUDE_PLUGIN_ROOT/preferences.json`:
   - Read existing file (if any) to preserve device preferences
   - Update simulator section with new choices INCLUDING udid
   - Write back to file

5. Continue to Step 5

### Step 5: Build with saved preferences

Read preferences from `$CLAUDE_PLUGIN_ROOT/preferences.json`.

**If `udid` exists in preferences**: Use it directly (fastest)
```bash
xcodebuild \
  -scheme "SAVED_SCHEME" \
  -destination "platform=iOS Simulator,id=SAVED_UDID" \
  build
```

**If `udid` is missing**: Look it up from device + ios_version, then update preferences:
```bash
# Lookup UDID
RUNTIME_KEY="com.apple.CoreSimulator.SimRuntime.iOS-26-2"
UDID=$(xcrun simctl list devices available -j | jq -r '.devices["'$RUNTIME_KEY'"][] | select(.name == "DEVICE_NAME" and .isAvailable) | .udid' | head -1)

# Build with UDID
xcodebuild -scheme "SAVED_SCHEME" -destination "platform=iOS Simulator,id=$UDID" build

# Update preferences.json to include the looked-up UDID for next time
```

## Example preferences.json

```json
{
  "simulator": {
    "scheme": "Signalsurf-DebugLocal",
    "device": "iPhone 16e",
    "ios_version": "iOS 26.2",
    "udid": "24A2580F-BABB-49D2-91EA-2B14498A4246"
  },
  "device": {
    "scheme": "Signalsurf-DebugRemote"
  }
}
```

## What Happens After Build

When build succeeds, the post-build hook automatically:
1. Boots the simulator (if not running)
2. Installs the app
3. Launches the app
