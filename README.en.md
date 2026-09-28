# Mountlane

[Русский](README.md)

**A free macOS file manager for disks.** Mountlane shows what is connected to your Mac, which file system it uses, and whether writing is safe.

## What it does

- Browse mounted APFS, HFS+, FAT32 and exFAT volumes.
- Show format, free space and the real read-only/read-write mode.
- Search and sort files, reveal hidden items, copy paths and open items in Finder.
- Copy multiple files or folders between disks.
- Check free space before copying.
- Keep both, skip, or replace name collisions after confirmation.
- Show transfer history and completion notifications.
- Safely eject removable media.
- Use English, Russian, or the macOS system language.

## NTFS without false promises

macOS normally mounts NTFS read-only. Mountlane makes that clear immediately.

If FUSE-T and NTFS-3G are already installed, open the NTFS volume and choose **Enable write access**. Mountlane shows a warning first and macOS asks for administrator authorization. If the components are missing, **Prepare NTFS** checks the system and opens their official sources.

Mountlane does not bundle, download, or install drivers. Before writing to an NTFS disk last used on Windows, safely eject it from Windows and disable Fast Startup/hibernation.

## Other formats

Mountlane provides a safe diagnostic state for ext4 and never enables writing through an unverified driver. For simple file exchange between Mac and Windows, exFAT is usually the easiest choice.

## Run it

1. Install Xcode 16 or newer.
2. Open `Package.swift` in Xcode.
3. Select the **Mountlane** scheme and press Run.

Minimum system version: macOS 15. The project is aimed at Apple Silicon.

## Data safety

- Copying never deletes source files.
- Replacing an existing item needs separate confirmation.
- A copy does not start when the destination lacks space.
- Writing status comes from macOS, never a guess.

## Free project

Mountlane is completely free: no ads, paid features, or trackers. Future support will be voluntary donations only, without feature unlocks.

## License and external components

Mountlane code is GPL-2.0-or-later. External NTFS component terms and the project policy are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
