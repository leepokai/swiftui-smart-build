---
description: Build for iOS Simulator and auto-install
---

# Simulator: Build → Boot → Install

Build for iOS Simulator with saved preferences.

## Workflow

### Step 1: Check for saved preferences

```bash
find . -maxdepth 1 -name ".smart-build.json"
```

**If no file is found** OR **no `simulator` section in preferences**:
→ Run the setup flow in `@../references/setup-flow.md`

**If simulator preferences exist**:
→ Go to Step 2

### Step 2: Build with saved preferences

Read preferences from `.smart-build.json` in the project root and run:

```bash
xcodebuild \
  -scheme "<SAVED_SCHEME>" \
  -destination "platform=iOS Simulator,id=<SAVED_UDID>" \
  build
# e.g., xcodebuild -scheme "App-DebugLocal" -destination "platform=iOS Simulator,id=24A2580F-BABB-49D2-91EA-2B14498A4246" build
```

## What Happens After Build

When build succeeds, the post-build hook automatically:
1. Boots the simulator (if not running)
2. Installs the app
3. Launches the app

**Do NOT run boot, install, or launch commands yourself.** The post-build hook handles everything automatically. Your job ends after a successful `xcodebuild` — never attempt to boot the simulator, install, or launch the app manually.
