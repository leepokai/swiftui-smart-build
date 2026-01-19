---
description: Install and launch the last built app on simulator/device
---

# Install Command

Install and launch the most recently built app on the configured destination.

## Instructions

1. **Check for config**: Read `.smart-build.json` to get destination settings
   - If no config exists, tell user to run `/swiftui-smart-build@leepokai:setup` first

2. **Get destination**:
   - If Xcode mode: Run `${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh`
   - If Custom mode: Use values from `.smart-build.json`

3. **Find the built app**:
   ```bash
   # For simulator
   PRODUCT_DIR="Debug-iphonesimulator"
   # For device
   # PRODUCT_DIR="Debug-iphoneos"

   APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/$PRODUCT_DIR/*.app" -type d 2>/dev/null | head -1)
   ```

4. **Get bundle ID**:
   ```bash
   BUNDLE_ID=$(defaults read "$APP_PATH/Info.plist" CFBundleIdentifier)
   ```

5. **Install and launch**:

   For **Simulator**:
   ```bash
   # Boot if needed
   xcrun simctl boot "$UDID" 2>/dev/null || true

   # Install
   xcrun simctl install "$UDID" "$APP_PATH"

   # Launch
   xcrun simctl launch "$UDID" "$BUNDLE_ID"

   # Open Simulator app
   open -a Simulator
   ```

   For **Device** (iOS 17+):
   ```bash
   # Install
   xcrun devicectl device install app --device "$UDID" "$APP_PATH"

   # Launch
   xcrun devicectl device process launch --device "$UDID" "$BUNDLE_ID"
   ```

6. **Report result**: Tell user the app is now running on [device name].
