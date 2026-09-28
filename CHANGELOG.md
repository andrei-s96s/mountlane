# Changelog

All notable changes to Mountlane are documented here.

## 1.0.0 — 2026-09-28

### Added

- Native macOS volume browser with APFS, HFS+, FAT32 and exFAT status detection.
- Russian, English and system-language interface modes.
- File search, sorting, hidden-file toggle, breadcrumbs, Finder reveal and path copy.
- Safe eject, NTFS readiness assistant, optional NTFS-3G remount flow and ext4 safety diagnostics.
- Copy transfers with capacity preflight, conflict policies, persistent operation history and notifications.
- GitHub Actions macOS build, tests and tag-based release packaging.

### Safety

- Mountlane never bundles, downloads or installs FUSE-T, NTFS-3G or another filesystem driver.
- Replacing files requires an explicit confirmation.
