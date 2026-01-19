---
name: setup
description: First-time setup for Smart Build. Run this when user first uses the plugin or wants to configure build settings. Ask user to choose between Xcode sync mode or custom settings.
---

# Smart Build Setup

First-time configuration for the Smart Build plugin.

## When to Use

- User's first time using smart-build in this project
- No `.smart-build.json` exists in the project root
- User explicitly asks to setup or configure smart-build

## ⚠️ IMPORTANT: Check Directory First

Before doing anything, verify user is in a valid Xcode project directory:

```bash
# Check for Xcode project
ls *.xcodeproj 2>/dev/null || ls *.xcworkspace 2>/dev/null
```

**If no project found**:
- STOP and warn the user:
  "⚠️ No Xcode project found in current directory.
   Please run Claude from your project folder:

   cd /path/to/YourApp
   claude

   Then run /swiftui-smart-build@leepokai:setup again."
- Do NOT create .smart-build.json

**If project found**: Continue with setup.

## Setup Flow

### Step 1: Check for existing config

```bash
# Check if config exists
cat .smart-build.json 2>/dev/null
```

If exists, tell user current settings and ask if they want to change.

### Step 2: Ask user preference

Use AskUserQuestion to ask:

**Question**: "How do you want Smart Build to determine build settings?"

**Options**:
1. **Xcode Sync** (Recommended) - Automatically use whatever scheme and destination is selected in Xcode
2. **Custom** - Specify a fixed scheme and destination

### Step 3A: If Xcode Sync mode

1. Read current Xcode settings to show user:
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
```

2. Create config file:
```json
{
  "mode": "xcode",
  "projectPath": null
}
```

3. Tell user: "Smart Build will now sync with Xcode. Currently: [scheme] → [destination]"

### Step 3B: If Custom mode

1. List available schemes:
```bash
xcodebuild -project *.xcodeproj -list -json 2>/dev/null | jq -r '.project.schemes[]'
# or for workspace
xcodebuild -workspace *.xcworkspace -list -json 2>/dev/null | jq -r '.workspace.schemes[]'
```

2. Ask user to pick a scheme

3. List available destinations:
```bash
# Booted simulators
xcrun simctl list devices booted -j | jq -r '.devices[][] | "\(.name) (Simulator) - \(.udid)"'

# Available simulators
xcrun simctl list devices available -j | jq -r '.devices[][] | select(.name | contains("iPhone")) | "\(.name) (Simulator) - \(.udid)"' | head -10

# Connected devices
xcrun devicectl list devices -j 2>/dev/null | jq -r '.result.devices[] | "\(.deviceProperties.name) (Device) - \(.identifier)"'
```

4. Ask user to pick a destination

5. Create config file:
```json
{
  "mode": "custom",
  "scheme": "UserSelectedScheme",
  "destination": {
    "type": "simulator",
    "udid": "12345678-ABCD-1234-ABCD-123456789ABC",
    "name": "iPhone 16 Pro",
    "platform": "iphonesimulator"
  }
}
```

### Step 4: Save config

Write the config to `.smart-build.json` in the project root.

### Step 5: Confirm

Tell user:
- "Setup complete!"
- "Your builds will now use: [scheme] → [destination]"
- "Run `/swiftui-smart-build:settings` anytime to change this"

## Example Conversation

```
User: /swiftui-smart-build:setup

Claude: I'll help you set up Smart Build for this project.

How do you want to determine build settings?

[Xcode Sync] - Automatically use Xcode's current scheme and destination
[Custom] - Specify a fixed scheme and destination

User: Xcode Sync

Claude: Reading your Xcode settings...

Current Xcode configuration:
- Scheme: SmartBuildTest
- Destination: iPhone 16 Pro (Simulator)

I've saved this preference. Smart Build will now automatically sync with
whatever you have selected in Xcode.

Setup complete! When you build, it will use your Xcode settings.
Run /swiftui-smart-build:settings anytime to change this.
```
