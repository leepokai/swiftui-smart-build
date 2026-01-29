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

### 2. Pre-Build Type Check

```
mcp__ide__getDiagnostics()
```

Fix any type errors before building.

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
│  Pre-Build                                      │
│  mcp__ide__getDiagnostics() → type check        │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Build & Deploy (Automatic)                     │
│  xcodebuild → Boot → Install → Launch           │
└─────────────────────────────────────────────────┘
```

---

## Troubleshooting

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
