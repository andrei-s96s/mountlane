# 1.0.0 release checklist

Run this checklist on an Apple Silicon Mac before creating `v1.0.0`.

## Automated checks

- [ ] The `main` CI run is successful.
- [ ] `swift build --configuration release` succeeds in Xcode 16+.
- [ ] `swift test` succeeds.
- [ ] `VERSION` matches the planned tag without the `v` prefix.

## Real-device checks

- [ ] Browse, search, sort and safely eject APFS, exFAT and FAT32 volumes.
- [ ] Copy a file and a folder to exFAT; test Keep both, Skip and Replace.
- [ ] Verify insufficient-space handling with a destination volume that is too small.
- [ ] Disconnect a source disk during a copy and confirm that Mountlane reports the failure without deleting source data.
- [ ] Attach a read-only NTFS volume and verify the NTFS readiness screen.
- [ ] On a test-only NTFS volume with user-installed FUSE-T and NTFS-3G, test the confirmed remount flow and write a disposable file.
- [ ] Attach ext4 and confirm that Mountlane presents a safety diagnostic rather than claiming write support.

## Release checks

- [ ] `THIRD_PARTY_NOTICES.md` is included and no driver binary is in the archive.
- [ ] Review `CHANGELOG.md` and release notes.
- [ ] Create an annotated tag: `git tag -a v1.0.0 -m "Mountlane 1.0.0"`.
- [ ] Push the tag and confirm the Release workflow publishes its ZIP artifact.

Do not mark the release as stable if any real-device safety check is incomplete.
