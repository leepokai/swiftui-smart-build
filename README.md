# SwiftUI Smart Build

Claude Code plugin for Swift/SwiftUI development with automatic code checking and app deployment.

## How It Works

### Auto Check & Format (on Edit/Write)

When you edit a `.swift` file, the plugin automatically:
- Runs `swiftc -parse` to catch syntax errors
- Runs `swiftformat` to auto-fix style issues (only when syntax is OK)

### Auto Install (on Build Success)

When `xcodebuild` succeeds, the plugin automatically:
- Finds the compiled `.app` in DerivedData
- Boots a simulator if none is running
- Installs and launches the app

## Installation

### Option 1: Via Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add leepokai/swiftui-smart-build

# Install the plugin
/plugin install swiftui-smart-build@leepokai
```

### Option 2: Direct Install

```bash
/plugin add leepokai/swiftui-smart-build
```

## Commands

| Command | Description |
|---------|-------------|
| `/simulator-build-boot-install` | Build → boot simulator → install & launch |
| `/device-build-boot-install` | Build → install to connected device → launch |

## Skills

| Skill | Description |
|-------|-------------|
| `/swiftui-best-practice` | SwiftUI development best practices (Swift 6.x / 2025) |

### Auto-Load Best Practices

When you first use `/swiftui-best-practice`, you'll be asked:

> Would you like to enable auto-load for SwiftUI best practices?

If you agree, the skill will be added to your project's `CLAUDE.md`, so Claude automatically follows these practices when working with Swift files.

## Usage

Just build your project normally:

```
> Build my app for the simulator

Claude runs: xcodebuild -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

BUILD SUCCEEDED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Auto-installing after successful build
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Found: MyApp.app
🔖 Bundle: com.example.MyApp
📱 Target: iPhone 16 Pro

📲 Installing...
✅ Installed

🎬 Launching...
✅ Launched

🎉 App running on iPhone 16 Pro
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Supported Targets

- **iOS Simulator**: Auto-boots if needed
- **Physical iOS Device**: Requires device to be connected and trusted

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
| **Simulator running** | Faster install (auto-boots if not running) | `open -a Simulator` |

### Included Features

- **Swift lint hook**: Auto-checks syntax (`swiftc -parse`) and auto-formats (`swiftformat`) after each edit
- **Auto-install hook**: Detects "BUILD SUCCEEDED" and deploys to simulator/device
- **Swift LSP**: Auto-configured via `.lsp.json` (uses Xcode's built-in `sourcekit-lsp`)
- **Multi-simulator support**: Prioritizes booted simulator when multiple exist

## License

MIT
