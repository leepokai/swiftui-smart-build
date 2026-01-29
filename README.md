# SwiftUI Smart Build

Claude Code plugin for Swift/SwiftUI development with automatic code checking and app deployment.

## Why This Plugin?

### The Problem

When using AI to write Swift code, you often face:

1. **Endless context switching** - AI writes code → switch to Xcode → build fails → switch back to AI → fix → repeat
2. **Build failures from AI-generated code** - AI doesn't know about syntax errors until you try to build
3. **Manual deployment** - After each build, manually install and launch the app

### The Solution

This plugin creates a **tight feedback loop** that catches errors early and deploys automatically:

| Without Plugin | With Plugin |
|----------------|-------------|
| AI edits → Build → Fail → Fix → Build → Fail → ... | AI edits → **Instant syntax check** → Fix → Build → **Auto-deploy** |
| 5-10 build attempts to get it right | **Higher first-build success rate** |
| Switch between AI IDE ↔ Xcode ↔ Simulator | **Stay in AI IDE**, app appears automatically |

### Time Saved

- **No more Xcode switching** - Syntax errors caught instantly after each edit
- **No more manual deployment** - App installs and launches automatically after build
- **Fewer build cycles** - Catch errors before building, not after

---

## How It Works

### Auto Check & Format (on Edit/Write)

When you edit a `.swift` file, the plugin automatically:
- Runs `swiftc -parse` to catch syntax errors (~0.1s)
- Runs `swiftformat` to auto-fix style issues (only when syntax is OK)

Errors appear immediately - no need to wait for a full build.

### Pre-Build LSP Check (Optional)

Before building, use LSP to verify types - faster than waiting for xcodebuild:

```
LSP hover on new function → verify return type resolves
LSP findReferences on renamed symbol → verify all call sites updated
```

Catches type errors and broken references before the full build.

### Auto Install (on Build Success)

When `xcodebuild` succeeds, the plugin automatically:
- Boots the target simulator (using saved UDID for precision)
- Installs the compiled `.app`
- Launches the app

**You stay in the AI IDE. The app just appears on the simulator.**

---

## Installation

```bash
# Add the marketplace
/plugin marketplace add leepokai/swiftui-smart-build

# Install the plugin
/plugin install swiftui-smart-build@leepokai
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/simulator-build-boot-install` | Build → boot simulator → install & launch |
| `/simulator-build-boot-install revise` | Change simulator/scheme settings |
| `/device-build-boot-install` | Build → install to connected device → launch |
| `/device-build-boot-install revise` | Change device scheme settings |

### Build Preferences

On first use, commands will ask you to choose:
- **Scheme**: Which Xcode scheme to build
- **iOS Version**: Which iOS runtime to use
- **Device**: Which simulator device to use
- **UDID**: Auto-saved for precise simulator targeting

Preferences are saved to plugin folder (`preferences.json`):

```json
{
  "simulator": {
    "scheme": "MyApp-Debug",
    "device": "iPhone 16e",
    "ios_version": "iOS 26.2",
    "udid": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  },
  "device": {
    "scheme": "MyApp-Release"
  }
}
```

Use `revise` argument to change settings anytime.

---

## Skills

| Skill | Description |
|-------|-------------|
| `/smart-build-workflow` | Build workflow guide with hooks documentation |

---

## Usage

### First Time Setup

Load the workflow skill to configure your build preferences:

```
/smart-build-workflow
```

The skill will:
1. Check if `preferences.json` exists
2. If not found, guide you through interactive setup:
   - Choose your build scheme
   - Choose iOS version
   - Choose simulator device
   - Save preferences with UDID for precise targeting

To change settings later, use:

```
/simulator-build-boot-install revise
```

### Building Your App

After setup, just build your project:

```
> Build my app for the simulator

Claude runs: xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,id=XXXX' build

BUILD SUCCEEDED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Auto-installing after successful build
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Found: MyApp.app
🔖 Bundle: com.example.MyApp
📱 Target: iPhone 16e (iOS 26.2)

🚀 Booting: iPhone 16e
✅ Booted

📲 Installing...
✅ Installed

🎬 Launching...
✅ Launched

🎉 App running on iPhone 16e
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Workflow

```
┌─────────────────────────────────────────────────┐
│  During Editing (Automatic)                     │
│  ──────────────────────────                     │
│  Edit .swift → swiftc -parse (instant check)    │
│             → swiftformat (auto-fix)            │
│  Errors shown immediately, no build needed      │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Pre-Build (Manual)                             │
│  ─────────────────                              │
│  mcp__ide__getDiagnostics() → type check        │
│  Catch type errors before building              │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Build & Deploy (Automatic)                     │
│  ──────────────────────────                     │
│  xcodebuild → BUILD SUCCEEDED                   │
│  → Boot simulator (if needed)                   │
│  → Install app                                  │
│  → Launch app                                   │
│  Stay in AI IDE, app appears on simulator       │
└─────────────────────────────────────────────────┘
```

---

## Supported Targets

- **iOS Simulator**: Auto-boots the correct simulator using saved UDID
- **Physical iOS Device**: Requires device to be connected and trusted

---

## Requirements

### Required

| Requirement | Why | Install |
|-------------|-----|---------|
| **macOS** | iOS development only works on Mac | - |
| **Xcode** | Build tools + sourcekit-lsp (built-in) | App Store or [developer.apple.com](https://developer.apple.com/xcode/) |
| **jq** | JSON parsing for hook scripts | `brew install jq` |

### Optional

| Requirement | Why | Install |
|-------------|-----|---------|
| **swiftformat** | Auto-format on edit | `brew install swiftformat` |
| **ios-deploy** | Install to physical devices | `brew install ios-deploy` |

---

## Included Features

- **Swift syntax hook**: Auto-checks syntax (`swiftc -parse`) after each edit (~0.1s)
- **Swift format hook**: Auto-formats (`swiftformat`) when syntax is OK
- **Preferences validator**: Validates `preferences.json` after edit
- **Auto-install hook**: Detects "BUILD SUCCEEDED" and deploys to simulator/device
- **UDID-based targeting**: Boots the exact simulator you configured, not a random one
- **LSP integration**: Use `hover` and `findReferences` for pre-build type verification

---

## License

MIT
