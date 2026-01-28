# Device: Build → Install → Launch

Build for physical iOS device, install and launch automatically.

## Prerequisites

1. **Device connected** via USB or Wi-Fi
2. **Device trusted** on this Mac
3. **Signing configured** in Xcode (Team + Bundle ID)

## Usage

```bash
xcodebuild \
  -scheme "YOUR_SCHEME" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  build
```

## Check Connected Devices

```bash
xcrun devicectl list devices
```

## What Happens Automatically

When build succeeds, the hook will:
1. Find the built `.app` in DerivedData
2. Detect connected device
3. Install the app via `devicectl`
4. Launch the app

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No device found | Check USB connection, trust the Mac on device |
| Signing error | Open Xcode, configure Team in Signing & Capabilities |
| Install fails | Ensure device is unlocked, check provisioning profile |
