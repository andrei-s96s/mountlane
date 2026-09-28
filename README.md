# Mountlane

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

## Roadmap

1. **Foundation (current):** native volume discovery and a read-only-safe browser.
2. **Transfers:** queued copying, collision handling, verification, progress and operation log.
3. **Drivers:** diagnose optional NTFS/ext4 providers and expose only the operations they reliably support.
4. **Support:** an optional donation destination configured by the project owner; no donation SDK or tracking is included before that choice.

## Safety principles

- Never label a volume writable unless macOS reports it as writable.
- Never ship a bundled third-party file-system driver without license, compatibility and real-device tests.
- Always use macOS' normal unmount/eject path.

## License

License selection is intentionally deferred until the driver-integration strategy is decided. Do not copy GPL driver code into this project without making the corresponding licensing decision.
