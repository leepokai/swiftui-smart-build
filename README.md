# SwiftUI Smart Build

A Claude Code plugin that automatically builds, installs, and launches Swift/SwiftUI apps after code changes. Deploys to running simulator or connected device.

## Features

- **Auto Build & Deploy**: When Claude finishes coding and confirms a successful build, the app automatically installs and launches on your device
- **Smart Detection**: Automatically detects running simulator, connected device, scheme, and project type
- **LSP Support**: Includes SourceKit-LSP configuration for Swift code intelligence
- **Zero Configuration**: Works out of the box with any Xcode project or Swift package

## Installation

### 1. Add the Marketplace

```
/plugin marketplace add leepokai/swiftui-smart-build
```

### 2. Install the Plugin

```
/plugin install swiftui-smart-build
```

## Usage

### Load the Skill

To enable smart build capabilities, load the skill:

```
/swiftui-smart-build:smart-build
```

This teaches Claude how to:
1. Build your Swift/SwiftUI project
2. Detect the correct scheme and destination
3. Mark the app ready for auto-install when the conversation ends

### Workflow

```
┌─────────────────────────────────────────────────┐
│  During Conversation                            │
│                                                 │
│  1. Ask Claude to modify Swift code             │
│  2. Ask Claude to build the project             │
│  3. Claude builds until successful              │
│  4. Claude marks app ready for install          │
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

### Example

```
You: Fix the bug in ContentView.swift and build it

Claude: [Fixes the code]
Claude: [Runs xcodebuild]
Claude: ✅ Build succeeded! App is ready for install.

You: [End conversation]

→ App automatically installs and launches on iPhone 16 Pro simulator
```

## Destination Priority

The plugin automatically detects where to deploy:

1. **Running Simulator** (highest priority) - Uses the currently booted simulator
2. **Connected Device** - Uses a physically connected iOS device
3. **Available Simulator** - Falls back to any available iPhone simulator

## Requirements

- macOS with Xcode installed
- `sourcekit-lsp` (included with Xcode)
- For real device deployment: valid signing certificate

## Plugin Structure

```
swiftui-smart-build/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── .lsp.json                 # SourceKit-LSP config
├── commands/
│   └── build.md              # /build command
├── hooks/
│   └── hooks.json            # Stop hook for auto-install
├── scripts/
│   ├── auto-install.sh
│   └── mark-ready-to-install.sh
└── skills/
    └── smart-build/
        └── SKILL.md
```

## License

MIT

## Links

- [GitHub Repository](https://github.com/leepokai/swiftui-smart-build)
- [Claude Code Documentation](https://code.claude.com/docs)
