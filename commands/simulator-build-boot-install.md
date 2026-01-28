# Simulator: Build → Boot → Install

Build for iOS Simulator, auto-boot if needed, and install & launch automatically.

## Usage

```bash
xcodebuild \
  -scheme "YOUR_SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  build
```

## Find Available Simulators

```bash
xcrun simctl list devices available
```

## Common Destinations

| Device | Destination |
|--------|-------------|
| iPhone 16 Pro | `platform=iOS Simulator,name=iPhone 16 Pro` |
| iPhone 16 Pro Max | `platform=iOS Simulator,name=iPhone 16 Pro Max` |
| iPhone 16e | `platform=iOS Simulator,name=iPhone 16e` |
| iPad Pro 13" | `platform=iOS Simulator,name=iPad Pro 13-inch (M4)` |

## What Happens Automatically

When build succeeds, the hook will:
1. Find the built `.app` in DerivedData
2. Boot the target simulator (if not running)
3. Install the app
4. Launch the app
