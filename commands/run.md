---
description: Build, install, and launch the app (complete workflow)
---

# Run Command

Build the project, then immediately install and launch on the destination.

## Instructions

This command combines build + install into one workflow.

1. **Check for config**: Read `.smart-build.json` to get mode settings
   - If no config exists, tell user to run `/swiftui-smart-build@leepokai:setup` first

2. **Get build settings**:
   - If Xcode mode: Run `${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh`
   - If Custom mode: Use values from `.smart-build.json`

3. **Build the project**:
   ```bash
   XCWORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)
   XCODEPROJ=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)

   # Use workspace if exists, otherwise project
   xcodebuild -workspace "$XCWORKSPACE" \
     -scheme "$SCHEME" \
     -destination "platform=iOS Simulator,id=$UDID" \
     -configuration Debug \
     -allowProvisioningUpdates \
     build
   ```

4. **If build fails**: Show errors and offer to fix. Do not proceed to install.

5. **If build succeeds, find the app**:
   ```bash
   PRODUCT_DIR="Debug-iphonesimulator"  # or Debug-iphoneos for device
   APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/$PRODUCT_DIR/$SCHEME.app" -type d 2>/dev/null | head -1)
   BUNDLE_ID=$(defaults read "$APP_PATH/Info.plist" CFBundleIdentifier)
   ```

6. **Install and launch**:

   For **Simulator**:
   ```bash
   xcrun simctl boot "$UDID" 2>/dev/null || true
   xcrun simctl install "$UDID" "$APP_PATH"
   xcrun simctl launch "$UDID" "$BUNDLE_ID"
   open -a Simulator
   ```

   For **Device** (iOS 17+):
   ```bash
   xcrun devicectl device install app --device "$UDID" "$APP_PATH"
   xcrun devicectl device process launch --device "$UDID" "$BUNDLE_ID"
   ```

7. **Report result**: Tell user the app is now running on [device name].

## Note

This command installs immediately. If you want the app to auto-install when the conversation ends, use the `smart-build` skill instead.
