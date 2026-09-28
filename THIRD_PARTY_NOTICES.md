# Third-party component notices

## Current distribution status

Mountlane does not ship FUSE-T, NTFS-3G, macFUSE, a filesystem extension, a kernel extension, or any binary built from those projects. The current release archive contains only Mountlane and its own resources.

The NTFS setup assistant links users to official component sources. Driver discovery checks local paths only. The remount action runs a driver already installed on the user's Mac, only after confirmation and macOS administrator authorization.

## FUSE-T

- Project: <https://github.com/macos-fuse-t/fuse-t>
- License terms: <https://github.com/macos-fuse-t/fuse-t/blob/main/License.txt>
- Mountlane relationship: not included or redistributed.

The FUSE-T binary license states that commercial use or bundling with commercial software requires a commercial license. Do not bundle its package, framework, libraries, headers, server components, or a derivative build into Mountlane without written permission from the FUSE-T authors.

## NTFS-3G

- Project: <https://github.com/tuxera/ntfs-3g>
- License: GNU General Public License (GPL).
- Mountlane relationship: not included, linked, compiled, or redistributed.

If a future Mountlane release distributes NTFS-3G source or binary, it must first satisfy every applicable GPL distribution obligation, including providing the corresponding source and required notices. Obtain legal review before changing the current external-component model.

## Trademarks and endorsement

FUSE-T, NTFS-3G, macFUSE, Apple, macOS and their logos may be trademarks of their respective owners. Names in this repository identify compatibility or an external component only. Mountlane does not claim affiliation, sponsorship, approval, or endorsement.

## Maintainer release checklist

Before publishing a release, confirm all of the following:

1. No third-party filesystem runtime or driver is in the application bundle, `.dmg`, ZIP archive, installer, or build cache uploaded as an artifact.
2. The release notes identify NTFS-3G and FUSE-T as optional external dependencies, not included components.
3. No logo, badge, or wording implies sponsorship or certification.
4. If the distribution model changes, stop the release and obtain written licensing approval plus a GPL compliance review first.

This file is an engineering notice, not legal advice.
