# DreamTweaks

A prototype iOS customization app targeting the **iPhone 12** (6.1", notch, no Dynamic
Island). DreamTweaks recreates the *experience* of a Dynamic Island-style "Dynamic
Peninsula" and an Android-style "Second Space" using only public, App Store-safe APIs —
with a clearly isolated architecture for optional future jailbreak integration.

## Important: what this build environment could and couldn't do

This repository was assembled in a **Linux container with no Xcode, no Swift toolchain,
and no macOS** (`uname` reports Linux; `xcodebuild`/`swift` are not installed). Per the
project's own ground rules, nothing about a working build was assumed or faked:

- ✅ Complete Swift/SwiftUI source code for every feature in the spec
- ✅ A hand-authored `DreamTweaks.xcodeproj` (targets, build phases, groups, a shared
  scheme) wired up the same way Xcode itself would generate one
- ✅ Info.plist, asset catalog (app icon + accent color), unit tests
- ❌ **Not compiled, not run, not archived, and no IPA was exported.** That requires
  Xcode and the iOS SDK on macOS, which do not exist in this environment.

**You will need to open this in Xcode on a Mac to build it the first time**, and if
anything doesn't compile cleanly, that's the next thing to fix — this project has not
been verified against a real Xcode toolchain.

**Don't have a Mac?** `.github/workflows/build-ipa.yml` builds an unsigned IPA on
GitHub's hosted macOS runners — no Mac purchase or rental needed to get the build
artifact. You still need a real Mac/Xcode signature (Apple requires it) to run on a
physical device; see [SIDELOADING.md](SIDELOADING.md) for a no-Mac way to do that on
Linux with a free Apple ID.

## Building it yourself

1. Open `DreamTweaks/DreamTweaks.xcodeproj` in Xcode 15+ (iOS 16 SDK or newer).
2. Select the `DreamTweaks` scheme and an iPhone 12 (or iPhone 12-class) simulator or
   device.
3. Build & run (`⌘R`). First launch shows the onboarding flow.
4. Run tests with `⌘U`, or from the command line:
   ```
   xcodebuild test -project DreamTweaks/DreamTweaks.xcodeproj -scheme DreamTweaks \
     -destination 'platform=iOS Simulator,name=iPhone 12'
   ```
5. To produce a testable IPA for a real iPhone 12, you need a signing identity/Apple
   Developer team configured in Xcode's Signing & Capabilities tab (Automatic signing
   is fine). Then:
   ```
   xcodebuild archive -project DreamTweaks/DreamTweaks.xcodeproj -scheme DreamTweaks \
     -archivePath build/DreamTweaks.xcarchive
   xcodebuild -exportArchive -archivePath build/DreamTweaks.xcarchive \
     -exportPath build/export -exportOptionsPlist ExportOptions.plist
   ```
   (`ExportOptions.plist` needs your team ID and `method: development` or `ad-hoc` for
   a testable, non-App-Store IPA — Xcode can generate one for you the first time you
   export manually from the Organizer.)

If Xcode reports a signing error, that's expected without a configured Apple Developer
account — the project itself is otherwise ready to build.

## What's implemented

- **Setup/onboarding** — Welcome, Appearance, Dynamic Peninsula toggle, Second Space
  toggle, Finish. Choices persist and are all editable later from Settings.
- **Home dashboard** — status cards for Dynamic Peninsula, Second Space, Appearance,
  and Privacy, plus a Test Lab shortcut.
- **Dynamic Peninsula** — an in-app view anchored to the iPhone 12's notch safe area
  (compact pill → expanded panel) with music, timer, charging, notification, and a
  Face ID-*style* animation state. Driven by `DynamicPeninsulaEngine` and fed by a
  `SimulatedSystemEventService` so it's fully testable without any system hooks.
- **Second Space** — a sandboxed, in-app "space" (own apps, notes, files, wallpaper,
  preferences) with a blur/zoom switch transition. This is the strongest sandboxed
  version an ordinary IPA can offer; see "Honesty about system integration" below.
- **Settings** — full sectioned settings tree matching the spec (DreamTweaks, Dynamic
  Peninsula, Second Space, Appearance, Animations, Privacy).
- **DreamTweaks Test Lab** — buttons to simulate every event the spec asks for (music,
  timer, charging, notifications, Second Space switching, Face ID animation) so the
  whole concept can be demonstrated without real system integration.
- **Unit tests** — preferences persistence, the Dynamic Peninsula engine's reaction to
  simulated events, the Second Space engine, the Mock Fingerprint manager's scan
  state machine, and `SystemIntegrationEngine`'s capability reporting.
- **Mock Touch Fingerprint** (`Features/Fingerprint/`) — an invisible, configurable
  touch zone (default: bottom-center) that runs a purely visual contact → reading →
  success/failure scan sequence, with a draggable position editor, a Lock Screen Demo,
  a repeatable Test Sensor screen, and status surfaced in the Dynamic Peninsula. It
  never reads, stores, or evaluates a real fingerprint and never touches Face ID, Touch
  ID, or the passcode — see "Honesty about system integration" below and the in-app
  copy, which always says "Mock Fingerprint Sensor" / "simulation."

## Honesty about system integration

`Core/Services/SystemIntegrationEngine.swift` is the seam the spec asks for. The
shipping build always uses `PublicAPIIntegration`, which explicitly reports (rather
than fakes) which features are out of reach of an ordinary App Store app:

- A true system-wide overlay above other apps (a real notch-to-Dynamic-Island
  transform) requires SpringBoard-level access.
- A true OS-level Second Space user profile that hides other installed apps requires
  MobileInstallation/SpringBoard access.
- Face ID *hardware* authentication is never touched — DreamTweaks only shows a
  Face ID-*style* animation for its own in-app lock, never claiming to replace Apple's
  actual biometric security.
- The iPhone 12 has no under-display fingerprint sensor, no Touch ID, and Apple exposes
  no raw biometric capture/match APIs to third-party apps. Mock Touch Fingerprint never
  captures an image, never accesses biometric hardware, and never claims the user was
  biometrically identified — the scan result is a locally simulated coin flip / fixed
  outcome, and it cannot bypass Face ID, the passcode, or the real iOS Lock Screen.

`JailbreakIntegration` is an empty, documented stub for a future opt-in backend. It
contains no exploit code and invents no private APIs — every method currently reports
"not implemented."

## Project layout

```
DreamTweaks/
  DreamTweaks.xcodeproj/
  DreamTweaks/
    App/                 App entry point, root routing, app-wide state
    Core/
      Models/             Preferences, Peninsula, Second Space data models
      Services/            Engines: DynamicPeninsula, SecondSpace, SystemIntegration,
                            simulated events, haptics
      Storage/              UserDefaults-backed persistence
      UI/                   iPhone 12 layout constants
    Features/
      Setup/                Onboarding flow
      Home/                 Dashboard
      Fingerprint/          Mock Touch Fingerprint sensor, view, Lock Screen Demo,
                            Test Sensor, position editor
      DynamicPeninsula/     Peninsula overlay + states
      SecondSpace/          Space switching UI
      Settings/             Settings screens
      TestLab/              Developer Test Lab
    Resources/              Info.plist, Assets.xcassets
  DreamTweaksTests/         XCTest unit tests
```

## iPhone 12 design target

Layout constants in `Core/UI/DeviceLayout.swift` target the iPhone 12's 6.1" display
(390×844 pt / 1170×2532 px) and its physical notch — not a Dynamic Island device. The
Dynamic Peninsula's compact state is sized to the notch's real safe-area geometry.
