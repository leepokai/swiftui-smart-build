# Boot Simulator

Start an iOS Simulator.

## List Available Simulators

```bash
xcrun simctl list devices available
```

## Check Booted Simulators

```bash
xcrun simctl list devices booted
```

## Boot a Simulator

```bash
# Boot by name
xcrun simctl boot "iPhone 16 Pro"

# Boot by UDID
xcrun simctl boot "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Open Simulator app (makes it visible)
open -a Simulator
```

## Shutdown Simulator

```bash
# Shutdown specific simulator
xcrun simctl shutdown "iPhone 16 Pro"

# Shutdown all
xcrun simctl shutdown all
```

## Common Simulator Names

- iPhone 16 Pro
- iPhone 16 Pro Max
- iPhone 16
- iPhone 15 Pro
- iPad Pro (12.9-inch)
- iPad Air

## One-liner: Boot and Open

```bash
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null; open -a Simulator
```
