---
name: smart-build-workflow
description: SwiftUI build workflow with automatic syntax checking, formatting, and app deployment.
---

# Smart Build Workflow

Automated build workflow for iOS development with syntax checking, auto-formatting, and instant deployment.

---

## Quick Start

### 1. Check Preferences (REQUIRED FIRST STEP)

```bash
cat "$CLAUDE_PLUGIN_ROOT/preferences.json" 2>/dev/null
```

**⚠️ CRITICAL**: If preferences.json does NOT exist or the command returns empty:
- You MUST run the setup flow in `@references/setup-flow.md` BEFORE proceeding
- DO NOT skip this step - build will fail without proper preferences
- DO NOT guess or hardcode values - follow the interactive setup

**If preferences.json exists** → Extract `scheme` and `udid`, then proceed to step 2

### 2. LSP Quick Check (Optional, Recommended for Large Changes)

Use LSP to verify types BEFORE building - faster than waiting for xcodebuild to fail.

**After adding/modifying functions:**
```
LSP hover on new function signature → verify return type resolves
```

**After renaming symbols:**
```
LSP findReferences on renamed symbol → verify all call sites updated
```

**After importing new modules:**
```
LSP hover on imported type → verify module is available
```

Example:
```swift
// You just added this function
func fetchUser(id: String) -> User { ... }
```
```
LSP hover at "fetchUser" → Returns "(String) -> User" ✓ types correct
LSP hover at "User" → Returns "struct User" ✓ type exists
```

If LSP returns error or empty → fix before building.

### 3. Build

```bash
xcodebuild \
  -scheme "SAVED_SCHEME" \
  -destination "platform=iOS Simulator,id=SAVED_UDID" \
  build
```

### 4. Auto-Deploy (Hook)

When build succeeds, hook automatically:
1. Boots target simulator (if needed)
2. Installs app
3. Launches app

---

## Automatic Hooks

### Swift Lint Check (on Edit/Write .swift)

- `swiftc -parse` - instant syntax check
- `swiftformat` - auto-fix style (when syntax OK)

### Auto-Install (on xcodebuild success)

- Extracts UDID from destination (PRIORITY 0)
- Boots simulator if needed
- Installs and launches app

**Simulator Selection Priority**:
```
PRIORITY 0: UDID from destination (id=XXXX)
PRIORITY 1: Booted simulator matching name
PRIORITY 2: Any booted simulator
PRIORITY 3: Available simulator matching name
PRIORITY 4: First available iPhone
```

### Preferences Validator (on Edit/Write preferences.json)

Validates JSON syntax and required fields.

---

## Commands

| Command | Description |
|---------|-------------|
| `/simulator-build-boot-install` | Build with saved preferences |
| `/simulator-build-boot-install revise` | Change settings (runs setup flow) |
| `/device-build-boot-install` | Build for physical device |

---

## Workflow Summary

```
┌─────────────────────────────────────────────────┐
│  During Editing (Automatic)                     │
│  Edit .swift → swiftc -parse → swiftformat      │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Pre-Build (Optional LSP Check)                 │
│  LSP hover → verify types                       │
│  LSP findReferences → verify no broken refs     │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Build & Deploy (Automatic)                     │
│  xcodebuild → Boot → Install → Launch           │
└─────────────────────────────────────────────────┘
```

---

## Troubleshooting (Only When User Requests)

Do NOT proactively run troubleshooting steps. Only use when user explicitly asks to debug or check logs.

```bash
# Check logs
cat /tmp/swiftui-smart-build/swift-lint-check.log
cat /tmp/swiftui-smart-build/post-build-install.log
cat /tmp/swiftui-smart-build/validate-preferences.log
```

| Problem | Solution |
|---------|----------|
| Hook not triggering | `which jq` - install if missing |
| Wrong simulator | `/simulator-build-boot-install revise` |
| No install after build | Check post-build-install.log |
