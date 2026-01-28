---
name: swiftui-best-practice
description: SwiftUI development best practices, performance optimization, and build workflow. Use when working with .swift files or SwiftUI views.
---

# SwiftUI Build Best Practice

## Auto-Load Setup

**First time using this skill?** Ask the user:

> Would you like to enable auto-load for SwiftUI best practices?
> This will add a reference to your project's `CLAUDE.md` so these practices are automatically applied when working with Swift files.

If user agrees, add to `CLAUDE.md` in project root:

```markdown
## SwiftUI Development

When working with Swift/SwiftUI files, follow best practices from:
@swiftui-smart-build:swiftui-best-practice

Key reminders:
- Syntax & format errors are auto-checked after each edit (via PostToolUse hook)
- Before building, run LSP getDiagnostics once for full type checking
- After xcodebuild succeeds, app auto-installs to device/simulator
- Keep view bodies simple and computation-free
```

---

## Core Principles

### 1. Always Rebuild After Changes

**CRITICAL**: After modifying any SwiftUI code:

1. **Rebuild immediately** to catch compile errors early
2. **Test on device/simulator** to verify visual changes
3. **Check for runtime warnings** in console

```bash
# Quick rebuild
xcodebuild -scheme "APP" -destination "platform=iOS Simulator,name=iPhone 16 Pro" build
```

### 2. Keep View Bodies Pure

The `body` property should ONLY describe layout. Never:
- Perform network calls
- Do heavy computation
- Modify state directly

```swift
// ❌ BAD
var body: some View {
    let result = expensiveCalculation() // Don't compute here
    Text(result)
}

// ✅ GOOD
var body: some View {
    Text(cachedResult) // Use pre-computed value
}
```

### 3. Minimize View Invalidation

Each `@State` / `@Binding` / `@ObservedObject` change triggers re-render.

```swift
// ❌ BAD - Entire view re-renders when ANY property changes
class ViewModel: ObservableObject {
    @Published var name: String
    @Published var age: Int
    @Published var avatarURL: URL
}

// ✅ GOOD - Split into focused subviews
struct ProfileView: View {
    var body: some View {
        VStack {
            AvatarView()      // Only re-renders when avatar changes
            NameView()        // Only re-renders when name changes
        }
    }
}
```

---

## Performance Best Practices (Swift 6.x / 2025)

### State Management

| Wrapper | Use When |
|---------|----------|
| `@State` | Simple value types owned by this view |
| `@StateObject` | Creating ObservableObject in this view |
| `@ObservedObject` | ObservableObject passed from parent |
| `@EnvironmentObject` | Shared across many views |
| `@Binding` | Two-way connection to parent's state |

**Rule**: Prefer `@StateObject` over `@ObservedObject` when instantiating objects to avoid reinitialization.

### Lazy Loading for Lists

```swift
// ❌ BAD - Loads ALL items immediately
VStack {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// ✅ GOOD - Only renders visible items
LazyVStack {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

Use `LazyVStack`, `LazyHStack`, `LazyVGrid` for:
- Lists with 20+ items
- Items with images or complex layouts
- Infinite scroll / pagination

### Stable Identifiers

```swift
// ❌ BAD - Unstable ID causes full re-render
ForEach(items, id: \.self) { item in ... }

// ✅ GOOD - Stable ID enables efficient diffing
ForEach(items, id: \.id) { item in ... }
```

### Expensive Modifiers

These are GPU-heavy, use sparingly:
- `.shadow()`
- `.blur()`
- `.opacity()` (when animated)
- `.mask()`

```swift
// ❌ BAD - Multiple shadow passes
Text("Hello")
    .shadow(radius: 2)
    .shadow(radius: 4)
    .shadow(radius: 6)

// ✅ GOOD - Single overlay
Text("Hello")
    .overlay(
        Text("Hello")
            .blur(radius: 3)
            .opacity(0.3)
            .offset(y: 2)
    )
```

### Cache Formatters

```swift
// ❌ BAD - Creates formatter every render
var body: some View {
    Text(Date(), formatter: DateFormatter()) // New instance each time!
}

// ✅ GOOD - Reuse formatter
private static let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f
}()

var body: some View {
    Text(Date(), formatter: Self.dateFormatter)
}
```

---

## Build Configuration

### Debug vs Release

```bash
# Debug (faster build, slower app)
xcodebuild -configuration Debug build

# Release (slower build, optimized app)
xcodebuild -configuration Release build
```

### Optimization Levels

| Setting | Debug | Release |
|---------|-------|---------|
| `SWIFT_OPTIMIZATION_LEVEL` | `-Onone` | `-O` or `-Osize` |
| `GCC_OPTIMIZATION_LEVEL` | 0 | s (smallest) |
| `SWIFT_COMPILATION_MODE` | incremental | wholemodule |

### Clean Build When Needed

```bash
# Clean derived data (fixes 80% of ghost errors)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Or clean specific project
xcodebuild clean -scheme "APP"
```

### Parallel Builds

```bash
# Use all CPU cores
xcodebuild -jobs $(sysctl -n hw.ncpu) build
```

---

## Swift 6 Concurrency

### MainActor for UI

```swift
// ✅ UI updates must be on MainActor
@MainActor
class ViewModel: ObservableObject {
    @Published var items: [Item] = []

    func loadItems() async {
        let data = await fetchData()
        items = data // Safe - we're on MainActor
    }
}
```

### Async Image Loading

```swift
// ✅ Built-in AsyncImage (iOS 15+)
AsyncImage(url: imageURL) { image in
    image.resizable()
} placeholder: {
    ProgressView()
}
```

---

## Debugging Checklist

When something doesn't work:

1. **Clean Build**: `Cmd+Shift+K` or delete DerivedData
2. **Restart Preview**: `Cmd+Option+P`
3. **Check Console**: Look for runtime warnings
4. **Use Instruments**: Profile with SwiftUI template (Xcode 16+)

### Common Issues

| Problem | Solution |
|---------|----------|
| View not updating | Check if state is properly observed |
| Laggy scrolling | Use `LazyVStack`, reduce view complexity |
| Memory growing | Look for retain cycles in closures |
| Build fails | Clean DerivedData, restart Xcode |

---

## Plugin Hooks

This plugin provides two automatic hooks:

### 1. Swift Lint Check (PostToolUse: Edit/Write)

Runs automatically after every `.swift` file edit:
- **Syntax check**: `swiftc -parse` - catches parse errors
- **Auto-format**: `swiftformat` - automatically fixes style issues (only when syntax is OK)

Errors are displayed immediately. Format issues are auto-fixed.

### 2. Auto-Install (PostToolUse: Bash)

The `post-build-install.sh` hook automatically installs and launches your app after a successful build.

### Prerequisites

1. **jq must be installed** (for JSON parsing)
   ```bash
   brew install jq
   ```

2. **swiftformat** (optional, for auto-formatting)
   ```bash
   brew install swiftformat
   ```

3. **.swift-version file** (recommended for swiftformat)
   Create a `.swift-version` file in your project root to specify your Swift version:
   ```bash
   echo "6.0" > .swift-version
   ```
   This enables version-specific formatting rules and eliminates warnings.

4. **Swift LSP for type checking** (auto-configured)
   - This plugin automatically configures `sourcekit-lsp` for Swift diagnostics
   - Requires: macOS with Xcode installed (sourcekit-lsp is built-in)
   - Usage: `mcp__ide__getDiagnostics` before building for full type check

5. **Simulator should be running** (recommended)
   - The hook will try to boot one if none is running, but it's faster if already booted
   - Use `open -a Simulator` before building

### How It Finds Your App

The hook automatically finds the most recently built `.app` in DerivedData:
1. Searches `Build/Products/*-<platform>/` directories
2. Sorts by modification time (most recent first)
3. Works with **any scheme or configuration naming** - no hardcoded assumptions

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Any scheme naming convention | Works - finds by modification time, not config name |
| Multiple simulators with same name | Hook prioritizes the **booted** one |
| No simulator running | Hook boots the first available iPhone |
| Build output piped (e.g., `\| tail -3`) | Still works - hook reads from Claude's JSON input |
| Physical device build | Uses `xcrun devicectl` or `ios-deploy` |
| No device/simulator available | Hook exits gracefully with warning |
| Multiple projects in DerivedData | Uses most recently modified .app |

### Troubleshooting

If auto-install doesn't work:

1. **Check debug log**: `cat /tmp/post-build-install-debug.log`
2. **Verify simulator is booted**: `xcrun simctl list devices booted`
3. **Ensure jq is installed**: `which jq`

---

## Post-Edit Workflow

### During the Session (After Each Edit)

The plugin automatically checks your code after each `.swift` file edit via PostToolUse hook:

1. **Syntax check** (`swiftc -parse`) - catches parse errors instantly
2. **Auto-format** (`swiftformat`) - automatically fixes style issues

These run automatically - no manual action needed. Syntax errors are reported; format issues are auto-fixed.

**Loop**: Edit → (auto syntax/format check) → Fix if needed → Edit → ...

### Before Building (Type Check)

Before running `xcodebuild`, use LSP for full type checking:

```
mcp__ide__getDiagnostics with uri: "file:///path/to/YourFile.swift"
```

This catches errors that syntax-only checking misses:
- Type mismatches
- Missing imports
- Protocol conformance issues
- Concurrency warnings (Swift 6)
- Undefined symbols

> **Note**: LSP is auto-configured by this plugin. Requires Xcode installed on macOS.

### Final Build

Run `xcodebuild` to compile and auto-deploy:

```bash
xcodebuild -scheme "APP" -destination "platform=iOS Simulator,name=iPhone 16 Pro" build
```

The post-build hook automatically installs and launches the app.

### Summary

```
┌─────────────────────────────────────────────────┐
│  During Editing (Automatic)                     │
│  ──────────────────────────                     │
│  Edit .swift → Hook: swiftc -parse              │
│             → Hook: swiftformat (auto-fix)      │
│             → Fix syntax errors if any          │
│       ↑                                    │    │
│       └────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Before Build (Manual)                          │
│  ─────────────────────                          │
│  LSP getDiagnostics → Fix type errors           │
└─────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────┐
│  Build & Deploy (Automatic)                     │
│  ──────────────────────────                     │
│  xcodebuild → BUILD SUCCEEDED → Auto Install    │
└─────────────────────────────────────────────────┘
```

---

## References

- [Apple: Understanding SwiftUI Performance](https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance)
- [Apple: Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [WWDC 2025: Optimize SwiftUI with Instruments](https://developer.apple.com/wwdc25/)
- [Swift 6 Concurrency](https://www.swift.org/documentation/concurrency/)
