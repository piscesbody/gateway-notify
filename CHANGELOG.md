# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-04-10

### Changed
- Repositioned the project as a **Hermes Agent** fork instead of an OpenClaw-only project
- Rewrote README and Chinese README for Hermes terminology and workflow
- Rewrote SKILL.md for Hermes-native usage
- Rewrote MANUAL.md and MANUAL_zh.md for Hermes hook installation
- Rewrote CHANNELS.md around Hermes target syntax and home-channel routing
- Replaced the installer script with a Hermes-compatible hook installer

### Added
- Added Hermes-native hook assets: `hook/HOOK.yaml` and `hook/handler.py`
- Added Hermes environment variable configuration examples
- Added explicit explanation that this project solves restart notification, not automatic reply resumption

### Removed
- Removed misleading OpenClaw-specific setup flow from docs
- Removed OpenClaw-specific packaged `.skill` artifact from the Hermes fork

## [1.0.5] - 2026-03-09

### Fixed
- Cross-platform compatibility: replaced macOS-specific `sed` with `awk` for address escaping
- Script now works on Linux, macOS, and other Unix-like systems

## [1.0.3] - 2026-03-09

### Security
- Removed config file reading from MANUAL.md example code
- Removed personal account information from examples (privacy fix)

### Changed
- Updated SKILL.md examples to use generic placeholders
- Updated MANUAL.md handler example to not read openclaw.json

## [1.0.1] - 2026-03-09

### Security
- Added input validation for channel names and addresses
- Removed config file reading from handler (privacy improvement)
- Added proper escaping for shell command injection prevention
- Added SECURITY.md with detailed security and privacy information

### Changed
- Handler no longer reads `~/.openclaw/openclaw.json`
- Simplified notification message (removed model info)
- Improved error messages in setup script

## [1.0.0] - 2026-03-09

### Added
- Initial release
- Auto-notify on gateway startup
- Support for 5 messaging channels (iMessage, WhatsApp, Telegram, Discord, Slack)
- One-command setup script
- Complete English and Chinese documentation
- Gateway status display (model, time, port)
