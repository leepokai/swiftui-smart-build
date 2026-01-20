# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.1] - 2025-01-20

### Changed
- Build and install are now separated: Claude builds during conversation, app installs on conversation end
- `/run` now builds + marks for auto-install (app launches when conversation ends)
- `/build` now only builds (no auto-install)
- `/install` now only marks for install (for already-built apps)
- Stop hook now properly handles auto-install using marker file

### Fixed
- Stop hook now actually works (uses mark-ready-to-install.sh → auto-install.sh flow)

## [1.3.0] - 2025-01-20

### Added
- New scripts for better control: `build.sh`, `install.sh`, `launch.sh`, `find-app.sh`
- Scripts handle all xcodebuild and simctl operations

### Changed
- Skills now use strong language (YOU MUST) to ensure Claude follows instructions exactly
- Skills now call scripts instead of inline bash commands
- Commands simplified to load skills with emphasis on following instructions
- Reduced reliance on LLM improvisation

### Fixed
- Claude no longer uses AppleScript or constructs xcodebuild commands manually
- Config format strictly enforced (`mode: xcode` or `mode: custom`)

## [1.2.2] - 2025-01-20

### Fixed
- Commands now explicitly tell Claude to read skill files at exact paths
- Prevents Claude from improvising instead of following skill instructions

## [1.2.1] - 2025-01-19

### Fixed
- Removed unnecessary `matcher` field from Stop and SessionStart hooks
- Simplified command files to reference skills by name instead of file paths

### Added
- Added `settings` command

## [1.2.0] - 2025-01-19

### Added
- **Commands**: New slash command system for easier access
  - `/swiftui-smart-build@leepokai:setup` - First-time configuration
  - `/swiftui-smart-build@leepokai:build` - Build only (no install)
  - `/swiftui-smart-build@leepokai:install` - Install and launch last built app
  - `/swiftui-smart-build@leepokai:run` - Complete build + install + launch workflow

### Changed
- Reorganized build command to be build-only (separated from install)
- Updated README with command documentation

## [1.1.0] - 2025-01-19

### Added
- **Setup skill** (`/swiftui-smart-build:setup`) - First-time configuration wizard
- **Settings skill** (`/swiftui-smart-build:settings`) - View and modify build settings
- **Xcode Sync mode** - Automatically read scheme and destination from Xcode's current selection
- **Custom mode** - Specify fixed scheme and destination
- `get-xcode-settings.sh` script to read Xcode's UserInterfaceState

### Changed
- Device names in documentation replaced with generic examples
- All documentation now in English only

## [1.0.0] - 2025-01-18

### Added
- Initial release
- Auto build and deploy workflow for Swift/SwiftUI projects
- Stop hook for automatic install and launch after conversation ends
- SourceKit-LSP integration for Swift code intelligence
- Smart detection for:
  - Running simulator (highest priority)
  - Connected physical device
  - Available iPhone simulators
- `/swiftui-smart-build:smart-build` skill for guiding Claude
- `/swiftui-smart-build:build` command

### Supported
- Xcode projects (`.xcodeproj`)
- Xcode workspaces (`.xcworkspace`)
- Swift packages (`Package.swift`)
- iOS Simulator deployment
- Physical device deployment (iOS 17+ via `devicectl`)

[Unreleased]: https://github.com/leepokai/swiftui-smart-build/compare/v1.3.1...HEAD
[1.3.1]: https://github.com/leepokai/swiftui-smart-build/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/leepokai/swiftui-smart-build/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/leepokai/swiftui-smart-build/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/leepokai/swiftui-smart-build/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/leepokai/swiftui-smart-build/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/leepokai/swiftui-smart-build/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/leepokai/swiftui-smart-build/releases/tag/v1.0.0
