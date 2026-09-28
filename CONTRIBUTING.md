# Contributing to Mountlane

Thanks for helping improve Mountlane.

## Development checks

Before opening a pull request, run:

```sh
swift build --configuration release
swift test
```

Keep Russian and English localization files in sync. Do not add a third-party filesystem driver, its binary, or an installer to the repository or a release artifact.

## Releases

Release-only instructions, including real-device checks and tag verification, are in [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md). They are intentionally kept out of the user-facing README.
