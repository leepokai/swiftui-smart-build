# Build → Boot → Install

Build your iOS app, auto-boot simulator if needed, and install & launch automatically.

## Flow

```
xcodebuild → BUILD SUCCEEDED → Hook triggers → Boot simulator → Install .app → Launch
```

## Find Project Info

```bash
# List available schemes
xcodebuild -list

# List available simulators
xcrun simctl list devices available
```

## Build Commands

### For Simulator

```bash
xcodebuild \
  -scheme "YOUR_SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  build
```

### For Physical Device

```bash
xcodebuild \
  -scheme "YOUR_SCHEME" \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  build
```

### With Workspace (CocoaPods/SPM)

```bash
xcodebuild \
  -workspace "YOUR_APP.xcworkspace" \
  -scheme "YOUR_SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  build
```

## What Happens Automatically

When build succeeds (`BUILD SUCCEEDED`), the hook will:

1. Find the most recently built `.app` in DerivedData
2. Boot the target simulator (if not already running)
3. Install the app
4. Launch the app

No manual steps needed!
