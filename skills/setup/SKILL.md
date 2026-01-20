---
name: setup
description: This skill should be used when the user asks to "setup smart build", "configure build settings", "initialize smart build", "run setup", or uses the /setup command. First-time configuration for Smart Build plugin.
---

# Smart Build Setup Skill

## ⚠️ CRITICAL: READ THIS FIRST

**YOU MUST follow these instructions EXACTLY as written.**

**DO NOT:**
- ❌ Use Search or Glob tools
- ❌ Construct JSON yourself - use the scripts provided
- ❌ Use AppleScript or osascript
- ❌ Skip steps or change the order
- ❌ Improvise or use alternative methods
- ❌ Assume user preferences without asking

**YOU MUST:**
- ✅ Run the EXACT scripts shown in each step
- ✅ Use AskUserQuestion to ask user for mode preference
- ✅ Follow the step order: 1 → 2 → 3 → 4

---

## Step 1: Check Project Directory

**Run this script:**

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/check-project.sh
```

**If `"found": false`:** STOP and tell user:
> "No Xcode project found. Please run Claude from your project directory."

**If `"found": true`:** Continue to Step 2.

---

## Step 2: Check Existing Config

**Run:**

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

2. **Create config using script:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/create-config.sh xcode
```

3. **Tell user:** "Setup complete! Smart Build will sync with Xcode."

---

## Step 4B: Custom Mode

If user chose **Custom**:

1. **List available schemes:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-schemes.sh
```

2. **Ask user to pick a scheme** using AskUserQuestion

3. **List available destinations:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/list-destinations.sh
```

4. **Ask user to pick a destination** using AskUserQuestion

5. **Create config using script:**
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/create-config.sh custom "<SCHEME>" '{"type":"simulator","name":"<NAME>","udid":"<UDID>","platform":"iphonesimulator"}'
```

Replace `<SCHEME>`, `<NAME>`, `<UDID>` with user's selections.

---

## Complete Example Flow

```
User: /swiftui-smart-build:setup

Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/check-project.sh
Output: {"found": true, "type": "project", "path": "MyApp.xcodeproj"}

Claude: [Runs] cat .smart-build.json 2>/dev/null || echo "NO_CONFIG"
Output: NO_CONFIG

Claude: [Uses AskUserQuestion]
"How should Smart Build determine your build settings?"
- Xcode Sync (Recommended)
- Custom

User: Xcode Sync

Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/get-xcode-settings.sh
Output: {"scheme": "MyApp", "destination": {...}}

Claude: [Runs] ${CLAUDE_PLUGIN_ROOT}/scripts/create-config.sh xcode
Output: ✅ Created .smart-build.json (Xcode sync mode)

Claude: Setup complete! Smart Build will sync with Xcode.
        Currently: MyApp → iPhone 16 Pro
```

---

## DO NOT

❌ Do NOT use Search, Glob, or find commands - use check-project.sh
❌ Do NOT construct .smart-build.json manually - use create-config.sh
❌ Do NOT list schemes manually - use list-schemes.sh
❌ Do NOT list simulators manually - use list-destinations.sh
❌ Do NOT assume user wants Xcode sync - always ask with AskUserQuestion
