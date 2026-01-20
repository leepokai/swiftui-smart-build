---
name: setup
description: First-time setup for Smart Build. Configure build settings - choose between Xcode sync or custom mode.
---

# Smart Build Setup Skill

**YOU MUST follow these instructions EXACTLY. Do NOT improvise or skip steps.**

## CRITICAL RULES

1. **YOU MUST check for .xcodeproj first** - Do NOT create config if no project found
2. **YOU MUST use AskUserQuestion** - Do NOT assume user's preference
3. **YOU MUST use the exact config format** - Do NOT add extra fields
4. **YOU MUST use `get-xcode-settings.sh`** for showing Xcode settings - Do NOT use AppleScript

---

## Step 1: Check Project Directory

**YOU MUST run this command first:**

```bash
ls *.xcodeproj 2>/dev/null || ls *.xcworkspace 2>/dev/null || echo "NO_PROJECT"
```

**If output is "NO_PROJECT":** STOP and tell user:
> "No Xcode project found. Please run Claude from your project directory:
> ```
> cd /path/to/YourApp
> claude
> ```
> Then run `/swiftui-smart-build:setup` again."

**Do NOT proceed if no project found.**

---

## Step 2: Check Existing Config

**YOU MUST run:**

```bash
cat .smart-build.json 2>/dev/null || echo "NO_CONFIG"
```

**If config exists:** Show current settings and ask if user wants to reconfigure.

**If "NO_CONFIG":** Continue to Step 3.

---

## Step 3: Ask User Preference

**YOU MUST use AskUserQuestion with these exact options:**

```
Question: "How should Smart Build determine your build settings?"

Options:
1. "Xcode Sync (Recommended)" - Automatically use whatever is selected in Xcode
2. "Custom" - Specify a fixed scheme and destination
```

---

## Step 4A: Xcode Sync Mode

If user chose **Xcode Sync**:

1. **Show current Xcode settings:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
```

2. **Create config file with EXACTLY this format:**
```json
{
  "mode": "xcode"
}
```

3. **Write to file:**
```bash
echo '{"mode": "xcode"}' > .smart-build.json
```

4. **Tell user:** "Setup complete! Smart Build will sync with Xcode."

---

## Step 4B: Custom Mode

If user chose **Custom**:

1. **List available schemes:**
```bash
xcodebuild -project *.xcodeproj -list -json 2>/dev/null | jq -r '.project.schemes[]'
```

2. **Ask user to pick a scheme** using AskUserQuestion

3. **List available simulators:**
```bash
xcrun simctl list devices available -j | jq -r '.devices[][] | select(.isAvailable==true) | select(.name | contains("iPhone")) | "\(.name) - \(.udid)"' | head -10
```

4. **Ask user to pick a destination** using AskUserQuestion

5. **Create config file with EXACTLY this format:**
```json
{
  "mode": "custom",
  "scheme": "<USER_SELECTED_SCHEME>",
  "destination": {
    "type": "simulator",
    "name": "<DEVICE_NAME>",
    "udid": "<DEVICE_UDID>",
    "platform": "iphonesimulator"
  }
}
```

6. **Write config to `.smart-build.json`**

---

## Config Format

**Xcode mode (simple):**
```json
{
  "mode": "xcode"
}
```

**Custom mode:**
```json
{
  "mode": "custom",
  "scheme": "MyApp",
  "destination": {
    "type": "simulator",
    "name": "iPhone 16 Pro",
    "udid": "12345678-ABCD-1234-ABCD-123456789ABC",
    "platform": "iphonesimulator"
  }
}
```

---

## DO NOT

❌ Do NOT add fields like `xcodeSync`, `projectPath`, `defaultScheme`, `defaultDestination`
❌ Do NOT use AppleScript to get Xcode settings
❌ Do NOT skip asking user for their preference
❌ Do NOT create config if no .xcodeproj found
❌ Do NOT use any format other than what is specified above
