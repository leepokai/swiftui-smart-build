# SwiftUI Smart Build

A Claude Code plugin that automatically builds, installs, and launches Swift/SwiftUI apps after code changes. Deploys to running simulator or connected device.

## Features

- **Auto Build & Deploy**: When Claude finishes coding and confirms a successful build, the app automatically installs and launches on your device
- **Xcode Sync Mode**: Automatically use whatever scheme and destination is selected in Xcode
- **Custom Mode**: Specify fixed scheme and destination
- **LSP Support**: Includes SourceKit-LSP configuration for Swift code intelligence
- **Zero Config After Setup**: One-time setup, then fully automatic

## Installation

### 1. Add the Marketplace

```
/plugin marketplace add leepokai/swiftui-smart-build
```

### 2. Install the Plugin

```
/plugin install swiftui-smart-build@leepokai
```

## ⚠️ Important: Run From Project Directory

**Always start Claude from your Xcode project folder:**

```bash
cd /path/to/YourApp      # Your project with .xcodeproj
claude                    # Start Claude here
```

❌ **Do NOT run from home directory or other locations** - the plugin needs to find your `.xcodeproj` to work properly.

## Usage

### First-Time Setup

Run the setup skill to configure how Smart Build determines build settings:

```
/swiftui-smart-build@leepokai:setup
```

You'll be asked to choose:
- **Xcode Sync** (Recommended) - Automatically use Xcode's current scheme and destination
- **Custom** - Specify a fixed scheme and destination

### Build Your App

After setup, use these commands:

```
/swiftui-smart-build@leepokai:run      # Build + install + launch
/swiftui-smart-build@leepokai:build    # Build only
/swiftui-smart-build@leepokai:install  # Install last built app
```

Or simply tell Claude: "Build and run this app"

### Change Settings

To view or modify settings anytime:

```
/swiftui-smart-build@leepokai:settings
```

## Workflow

```
┌─────────────────────────────────────────────────┐
│  First Time: /swiftui-smart-build@leepokai:setup │
│                                                 │
│  Choose: [Xcode Sync] or [Custom]               │
│  → Settings saved to .smart-build.json          │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  During Conversation                            │
│                                                 │
│  1. Ask Claude to modify Swift code             │
│  2. Ask Claude to build                         │
│  3. Claude reads your settings automatically    │
│  4. Claude builds until successful              │
│  5. Claude marks app ready for install          │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  On Conversation End (Automatic)                │
│                                                 │
│  → Boot simulator (if needed)                   │
│  → Install app                                  │
│  → Launch app                                   │
│  → Your app is running!                         │
└─────────────────────────────────────────────────┘
```

## Configuration Modes

### Xcode Sync Mode

Smart Build reads your current Xcode selection from `UserInterfaceState.xcuserstate`. Whatever you have selected in Xcode is what gets built.

**Pros**: Always matches Xcode, no manual config needed
**Cons**: Must have project open in Xcode

### Custom Mode

You specify a fixed scheme and destination during setup. Smart Build always uses these settings.

**Pros**: Works without Xcode open, consistent builds
**Cons**: Need to update settings manually if you want to change

## Config File

Settings are stored in `.smart-build.json` in your project root:

```json
{
  "mode": "xcode"
}
```

Or for custom mode:

```json
{
  "mode": "custom",
  "scheme": "MyApp",
  "destination": {
    "type": "simulator",
    "udid": "12345678-ABCD-1234-ABCD-123456789ABC",
    "name": "iPhone 16 Pro",
    "platform": "iphonesimulator"
  }
}
```

## Commands

| Command | Description |
|---------|-------------|
| `/swiftui-smart-build@leepokai:setup` | First-time configuration wizard |
| `/swiftui-smart-build@leepokai:build` | Build only (no install) |
| `/swiftui-smart-build@leepokai:install` | Install and launch the last built app |
| `/swiftui-smart-build@leepokai:run` | Build + install + launch (complete workflow) |

## Skills

Skills are detailed instruction files that guide Claude through complex workflows. Commands load these skills automatically.

| Skill | Description |
|-------|-------------|
| `setup` | First-time configuration flow |
| `settings` | View/modify current settings |
| `smart-build` | Build with auto-install on conversation end |

## Requirements

- macOS with Xcode installed
- `sourcekit-lsp` (included with Xcode)
- For real device deployment: valid signing certificate

## License

MIT

## Links

- [GitHub Repository](https://github.com/leepokai/swiftui-smart-build)
- [Claude Code Documentation](https://code.claude.com/docs)
