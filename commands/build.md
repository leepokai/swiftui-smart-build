# Build Xcode Project

Build the iOS app using xcodebuild.

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
  -configuration Debug \
  build
```

### For Physical Device

```bash
xcodebuild \
  -scheme "YOUR_SCHEME" \
  -destination "generic/platform=iOS" \
  -configuration Debug \
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

## Notes

- After a successful build (BUILD SUCCEEDED), the app will be **automatically installed** via hook
- The compiled .app is in `~/Library/Developer/Xcode/DerivedData/`
