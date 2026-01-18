---
description: Build the Swift/SwiftUI project and prepare for auto-install on Stop
---

# Build Command

Build the current Swift/SwiftUI project. On success, mark it ready for auto-install when the conversation ends.

## Instructions

1. **Detect the project**:
   - Look for `.xcworkspace` (priority) or `.xcodeproj` in the current directory
   - For Swift packages, look for `Package.swift`

2. **Detect the scheme**:
   ```bash
   xcodebuild -project <path> -list -json
   # or
   xcodebuild -workspace <path> -list -json
   ```

3. **Detect the destination** (priority order):
   - Running simulator: `xcrun simctl list devices booted -j`
   - Connected device: `xcrun devicectl list devices -j`
   - Any available simulator: `xcrun simctl list devices available -j`

4. **Run the build**:
   ```bash
   xcodebuild -project <path> \
     -scheme <scheme> \
     -destination "platform=iOS Simulator,id=<udid>" \
     -configuration Debug \
     -allowProvisioningUpdates \
     build
   ```

5. **If build succeeds**:
   - Find the `.app` path from build output or DerivedData
   - Get bundle ID: `defaults read <app_path>/Info.plist CFBundleIdentifier`
   - Mark ready for install:
     ```bash
     ${CLAUDE_PLUGIN_ROOT}/scripts/mark-ready-to-install.sh \
       "<app_path>" "<bundle_id>" "<device_type>" "<device_udid>" "<device_name>"
     ```

6. **If build fails**:
   - Show the errors
   - Fix the code
   - Try again until successful

## Example

```bash
# 1. Build
xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination "platform=iOS Simulator,id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" \
  -configuration Debug build

# 2. On success, mark ready
/path/to/mark-ready-to-install.sh \
  "/Users/.../Debug-iphonesimulator/MyApp.app" \
  "com.example.MyApp" \
  "simulator" \
  "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" \
  "iPhone 16 Pro"
```

## After Conversation Ends

The Stop hook will automatically:
1. Check if a marker file exists
2. If yes: Install and launch the app on the destination
3. If no: Do nothing
