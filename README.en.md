# Mountlane

[Русский](README.md)

Native macOS disk and file manager for working across file systems.

Mountlane starts with the file systems macOS supports natively (APFS, HFS+, FAT32 and exFAT) and makes each volume's actual access mode explicit. Support for NTFS, ext4 and other formats is deliberately separated into driver modules: a file manager cannot safely make a read-only file system writable by itself.

## First milestone

- show mounted volumes and their file-system format;
- make read-only/read-write state, capacity and diagnostics clear;
- browse files and open the selected volume in Finder;
- safely eject removable/ejectable volumes;
- offer a Russian and English interface, with system-language detection;
- reserve an optional Support item for a future donation link.

## Run in Xcode

Open `Package.swift` in Xcode 16 or newer, select the **Mountlane** scheme, then run it. The current deployment target is macOS 15+, so it is compatible with Apple Silicon Macs running newer macOS releases.

## Continuous integration and releases

GitHub Actions builds the release configuration, validates both localization files and runs the unit tests on macOS for every push to `main` and every pull request targeting it.

To create a release artifact, push a semantic version tag such as `v0.1.0`. The release workflow builds the app executable, packages it with its localization resources and the README, and creates a GitHub Release. This initial artifact is **not code-signed or notarized**; release distribution outside developer testing must add Apple Developer signing and notarization secrets first.


## Roadmap

1. **Foundation (current):** native volume discovery and a read-only-safe browser.
2. **Transfers:** queued copying, collision handling, verification, progress and operation log.
3. **Drivers:** Mountlane recognizes NTFS volumes and an installed NTFS-3G provider, and offers controlled remounting through FUSE-T/NTFS-3G for a read-only volume. The command runs only after user confirmation and macOS system authorization. ext4 will use the same modular approach.
4. **Support:** an optional donation destination configured by the project owner; no donation SDK or tracking is included before that choice.

## Safety principles

- Never label a volume writable unless macOS reports it as writable.
- Never ship a bundled third-party file-system driver without license, compatibility and real-device tests.
- Always use macOS' normal unmount/eject path.

## NTFS, FUSE-T, and NTFS-3G

Mountlane does **not include, redistribute, modify, or compile** FUSE-T or NTFS-3G. It only checks for FUSE-T and a locally installed `ntfs-3g`, then invokes that user-installed driver to remount a specific NTFS volume only after explicit user action.

Users install these components from their official sources and accept their terms themselves. Mountlane is not affiliated with FUSE-T, NTFS-3G, or their authors, and does not claim endorsement.

FUSE-T publishes separate binary-distribution terms, including a commercial-license requirement for commercial use or bundling with commercial software. NTFS-3G is GPL-licensed. Mountlane does not plan to include either component in a `.dmg`, installer, or release archive; the Prepare NTFS button only checks the system and links to official sources. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Mountlane license

Mountlane source code is GPL-2.0-or-later. This applies to Mountlane code only and does not mean that FUSE-T or NTFS-3G are included in a release. The complete text is in [LICENSE](LICENSE).

## Project support

Mountlane remains completely free: no feature, including NTFS support, will be paid. A future voluntary donation link will not unlock features or add advertising or tracking. Third-party terms will be reviewed again before it is published.
