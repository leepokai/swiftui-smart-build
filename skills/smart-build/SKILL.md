---
name: smart-build
description: Build Swift/SwiftUI projects and deploy to simulator or device. Use when user wants to build, run, or deploy.
---

# Smart Build Skill

**YOU MUST follow these instructions EXACTLY. Do NOT improvise or use alternative methods.**

## CRITICAL RULES

1. **YOU MUST use the scripts provided** - Do NOT construct xcodebuild commands yourself
2. **YOU MUST read `.smart-build.json`** - Do NOT ask user for scheme/destination if config exists
3. **YOU MUST use `get-xcode-settings.sh`** for Xcode mode - Do NOT use AppleScript or other methods
4. **YOU MUST follow the exact step order** - Do NOT skip steps or change the order

---

## Step 1: Check Project Directory

**YOU MUST run this command first:**

```bash
ls *.xcodeproj 2>/dev/null || ls *.xcworkspace 2>/dev/null || echo "NO_PROJECT"
```

**If output is "NO_PROJECT":** STOP and tell user:
> "No Xcode project found. Please run Claude from your project directory."

---

## Step 2: Read Config

**YOU MUST run:**

```bash
cat .smart-build.json 2>/dev/null || echo "NO_CONFIG"
```

**If "NO_CONFIG":** Tell user to run `/swiftui-smart-build:setup` first, then STOP.

**If config exists:** Parse the JSON and continue.

---

## Step 3: Get Build Settings

### If `"mode": "xcode"`:

**YOU MUST run this script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
```

This returns JSON with `scheme` and `destination`. Use these values.

### If `"mode": "custom"`:

Use `scheme` and `destination` from `.smart-build.json` directly.

---

## Step 4: Build

**YOU MUST use the build script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/build.sh "<SCHEME>" "<DESTINATION>"
```

Where:
- `<SCHEME>` = scheme name from Step 3
- `<DESTINATION>` = destination string, e.g., `platform=iOS Simulator,name=iPhone 16 Pro`

**Example:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/build.sh "MyApp" "platform=iOS Simulator,name=iPhone 16 Pro"
```

**If build fails:** Show the error and offer to fix the code. Do NOT proceed to install.

**If build succeeds:** Continue to Step 5.

---

## Step 5: Find Built App

**YOU MUST run this script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/find-app.sh "<SCHEME>" "<PLATFORM>"
```

Where:
- `<SCHEME>` = same scheme name
- `<PLATFORM>` = `iphonesimulator` or `iphoneos`

**Example:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/find-app.sh "MyApp" "iphonesimulator"
```

This returns JSON with `app_path` and `bundle_id`. Save these for install.

---

## Step 6: Install

**YOU MUST use the install script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/install.sh "<DEVICE_TYPE>" "<DEVICE_NAME>" "<APP_PATH>"
```

Where:
- `<DEVICE_TYPE>` = `simulator` or `device`
- `<DEVICE_NAME>` = device name, e.g., `iPhone 16 Pro`
- `<APP_PATH>` = path from Step 5

**Example:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/install.sh "simulator" "iPhone 16 Pro" "/path/to/MyApp.app"
```

---

## Step 7: Launch

**YOU MUST use the launch script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/launch.sh "<DEVICE_TYPE>" "<DEVICE_NAME>" "<BUNDLE_ID>"
```

**Example:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/launch.sh "simulator" "iPhone 16 Pro" "com.example.MyApp"
```

---

## Complete Example Flow

```
User: /swiftui-smart-build:run

Claude: [Step 1] Checking for Xcode project...
Claude: [Runs] ls *.xcodeproj
Claude: Found SmartBuildTest.xcodeproj

Claude: [Step 2] Reading config...
Claude: [Runs] cat .smart-build.json
Claude: Mode is "xcode"

Claude: [Step 3] Getting Xcode settings...
Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
Claude: Scheme: SmartBuildTest, Destination: iPhone 16 Pro

Claude: [Step 4] Building...
Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/build.sh "SmartBuildTest" "platform=iOS Simulator,name=iPhone 16 Pro"
Claude: ✅ Build succeeded

Claude: [Step 5] Finding app...
Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/find-app.sh "SmartBuildTest" "iphonesimulator"
Claude: Found at /Users/.../SmartBuildTest.app

Claude: [Step 6] Installing...
Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/install.sh "simulator" "iPhone 16 Pro" "/Users/.../SmartBuildTest.app"
Claude: ✅ Installed

Claude: [Step 7] Launching...
Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/launch.sh "simulator" "iPhone 16 Pro" "com.example.SmartBuildTest"
Claude: ✅ App is running!
```

---

## DO NOT

❌ Do NOT use `osascript` or AppleScript
❌ Do NOT construct xcodebuild commands manually
❌ Do NOT modify `.smart-build.json` unless user asks
❌ Do NOT skip steps
❌ Do NOT use different scripts or methods than specified above
