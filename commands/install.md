# Install App

Manually install an app to simulator or device.

## Find the App

```bash
# Find compiled app in DerivedData
find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*/Debug-iphonesimulator/*" -type d 2>/dev/null

# For device builds
find ~/Library/Developer/Xcode/DerivedData -name "*.app" -path "*/Debug-iphoneos/*" -type d 2>/dev/null
```

## Install to Simulator

```bash
# Get booted simulator UDID
UDID=$(xcrun simctl list devices booted -j | jq -r '.devices[][] | select(.state == "Booted") | .udid' | head -1)

# Install
xcrun simctl install "$UDID" /path/to/YourApp.app

# Launch
xcrun simctl launch "$UDID" com.example.YourApp
```

## Install to Physical Device

```bash
# List connected devices
xcrun devicectl list devices

# Install (replace DEVICE_UDID)
xcrun devicectl device install app -d "DEVICE_UDID" /path/to/YourApp.app

# Launch
xcrun devicectl device process launch -d "DEVICE_UDID" com.example.YourApp
```

## Get Bundle ID

```bash
/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" /path/to/YourApp.app/Info.plist
```
