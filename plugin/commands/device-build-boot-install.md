---
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

```bash
find . -maxdepth 1 -name ".smart-build.json"
```

**If no file is found** OR **no `device` section in preferences**:
→ Run the setup flow in `@../references/setup-flow.md` (device only needs scheme selection)

**If device preferences exist**:
→ Go to Step 2

### Step 2: Build with saved preferences

Read preferences from `.smart-build.json` in the project root and run:

```bash
xcodebuild \
  -scheme "<SAVED_SCHEME>" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  build
# e.g., xcodebuild -scheme "App-DebugRemote" -destination "generic/platform=iOS" -allowProvisioningUpdates build
```

## What Happens After Build

When build succeeds, the post-build hook automatically:
1. Detects connected device
2. Installs the app via `devicectl`
3. Launches the app

**已經自動 boot / install / launch，不需要再作改動。**

## Check Connected Devices

```bash
xcrun devicectl list devices
```

## Troubleshooting (Only When User Requests)

Do NOT proactively run troubleshooting steps. Only use when user explicitly asks to debug.

| Issue | Solution |
|-------|----------|
| No device found | Check USB connection, trust the Mac on device |
| Signing error | Open Xcode, configure Team in Signing & Capabilities |
| Install fails | Ensure device is unlocked, check provisioning profile |
