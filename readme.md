# Pushup for iOS

A small native SwiftUI starter for tracking push-up sets and a daily goal.

**Working assumption:** the repository name means a push-up fitness tracker. The product purpose has not been confirmed. This deliberately small implementation is easy to adapt; it does not imply a committed roadmap.

## First version

- Count repetitions manually, undo a repetition, or enter a completed set with a stepper.
- Save sets locally and see progress against a configurable daily goal (default 50).
- Review dated history and swipe to delete a saved set.
- Works offline without a backend, login, analytics, or third-party runtime dependencies.
- Supports iPhone and iPad on iOS 17 or later, system appearance, and Dynamic Type.

Unsaved repetitions reset when the app is terminated. Saved history uses versioned JSON in UserDefaults, suitable for this small prototype. Unreadable data is preserved and writes are blocked rather than silently erasing history. There is no export or sync yet. Device backups may include app data.

## Run on a Mac

Requirements: Xcode 16 or later with an iOS simulator, Homebrew, and XcodeGen.

```sh
brew install xcodegen
xcodegen generate
open Pushup.xcodeproj
```

Select the **Pushup** scheme and an iPhone simulator, then press Run. For a physical iPhone, set your development team under Signing & Capabilities and change the placeholder bundle identifier `com.example.pushup` in `project.yml` to one you own, then regenerate. Apple signing is required for device installation.

`project.yml` is the source of truth; the generated Xcode project is intentionally ignored. No API keys or secrets are needed.

## Structure

| Path | Purpose |
| --- | --- |
| `Pushup/App/` | App entry point and shared state |
| `Pushup/Models/` | Set model, daily totals, local persistence |
| `Pushup/Views/` | Today, History, and Settings tabs |
| `PushupTests/` | Persistence, date boundaries, and invalid-data tests |
| `project.yml` | XcodeGen app, scheme, and test configuration |
| `.github/workflows/ios.yml` | macOS simulator build and unit tests |
| `docs/DEVELOPMENT.md` | Validation, limitations, and next decisions |

## Test

After generating the project, use **Product → Test** in Xcode, or:

```sh
xcodebuild test -project Pushup.xcodeproj -scheme Pushup \
  -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO
```

Replace the simulator name with one installed on your Mac (`xcrun simctl list devices available`). CI selects an available iPhone automatically.

## Status

Source starter, not an App Store release. The creation environment has no Xcode or Swift toolchain, so compilation, simulator tests, and visual/device checks have not been run there. The macOS workflow provides the next verification step. App icon artwork, signing, distribution, and final product requirements remain to be defined. No license has been selected; repository visibility alone does not grant reuse rights.
