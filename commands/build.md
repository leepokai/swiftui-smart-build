---
description: Build the Swift/SwiftUI project (build only, no install)
---

# Build Command

Build the current Swift/SwiftUI project without installing.

## Instructions

1. **Check for config**: Read `.smart-build.json` to get mode settings
   - If no config exists, tell user to run `/swiftui-smart-build@leepokai:setup` first

2. **Get build settings**:
   - If Xcode mode: Run `${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh`
   - If Custom mode: Use values from `.smart-build.json`

3. **Find project**:
   ```bash
   XCWORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" ! -path "*/.*" | head -1)
   XCODEPROJ=$(find . -maxdepth 2 -name "*.xcodeproj" ! -path "*/.*" | head -1)
   ```

4. **Run the build**:
   ```bash
   # Use workspace if exists, otherwise project
   xcodebuild -workspace "$XCWORKSPACE" \
     -scheme "$SCHEME" \
     -destination "platform=iOS Simulator,id=$UDID" \
     -configuration Debug \
     -allowProvisioningUpdates \
     build
   ```

5. **Report result**:
   - If build succeeds: Tell user "Build succeeded"
   - If build fails: Show errors and offer to fix

This command only builds. Use `/swiftui-smart-build@leepokai:install` to install, or `/swiftui-smart-build@leepokai:run` to build and install together.
