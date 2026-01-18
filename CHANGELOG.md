# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/leepokai/swiftui-smart-build/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/leepokai/swiftui-smart-build/releases/tag/v1.0.0
