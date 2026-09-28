# Installing DreamTweaks on your iPhone 12 without a Mac (Linux)

Apple requires every app that runs on a real iPhone to be cryptographically
signed. There's no way around that step — but you don't need to own a Mac to
do it. This document covers the two things you need:

1. **Building the app** — done for you by GitHub Actions (see
   `.github/workflows/build-ipa.yml`), which produces an **unsigned** IPA.
2. **Signing + installing it** — done on your Linux machine using
   **AltServer-Linux**, a community reimplementation of AltStore's signing
   server, using your own free Apple ID. No paid developer account needed.

This is a real, working but somewhat involved community setup — it's more
moving parts than Sideloadly-on-Windows would be. If you ever get access to
a Windows machine (even a friend's, briefly), Sideloadly is much simpler.

## 1. Get the unsigned IPA

- Push to this branch (or trigger it manually): GitHub → **Actions** tab →
  **Build DreamTweaks IPA** → **Run workflow**.
- When it finishes, open the run and download the **DreamTweaks-unsigned-ipa**
  artifact. Unzip it to get `DreamTweaks-unsigned.ipa`.

This IPA has no signature at all — that's expected. AltServer signs it from
scratch during installation, the same way Sideloadly or Xcode would.

## 2. Set up AltServer-Linux

Project: <https://github.com/NyaMisty/AltServer-Linux>

You'll need:
- `libimobiledevice` + `usbmuxd` (talks to the iPhone over USB)
- Docker (easiest way to run the required "anisette" server, which stands in
  for the Apple-account-authentication data macOS normally provides)
- The `AltServer-Linux` binary itself

Rough steps (check that repo's README for current exact commands, since
sideloading tooling changes often):

```bash
# USB communication with the iPhone
sudo apt install usbmuxd libimobiledevice6 libimobiledevice-utils

# Anisette server (provides Apple auth data Linux doesn't have natively)
docker run -d --name anisette -p 6969:6969 --restart always dadoum/anisette-v3-server

# Get AltServer-Linux (see project releases page for the current build)
# and run it, pointing it at the anisette server:
./AltServer-Linux --anisette-server http://localhost:6969
```

- Plug in your iPhone 12 via USB and unlock it / tap "Trust This Computer".
- Confirm the device shows up: `idevice_id -l` and `ideviceinfo` should see it.
- Use AltServer-Linux's install command, pointing at the downloaded IPA:
  ```bash
  ./AltServer-Linux install DreamTweaks-unsigned.ipa --udid <your-device-udid>
  ```
- Sign in with your Apple ID when prompted (an app-specific password from
  appleid.apple.com may be required if you have two-factor auth on, which
  you should).

## 3. What to expect on a free Apple ID

- The app installs and runs like any other app once signed.
- A **free** Apple ID certificate expires after **7 days** — after that, the
  app needs to be re-signed/re-installed the same way (AltServer-Linux, or
  AltStore running on the phone itself if it can reach a "refresh" helper on
  your network — check that project's docs for its Wi-Fi refresh support on
  Linux, since it may be less complete than the Mac/Windows version).
- A free account is limited to a small number of sideloaded apps active at
  once (Apple's limit, currently 3 app IDs) — remove old test builds if you
  hit that cap.
- On first launch, iOS will refuse to open the app until you trust the
  developer certificate: **Settings → General → VPN & Device Management →**
  (your Apple ID) **→ Trust**.

## If this turns out to be too much friction

Reasonable fallbacks, roughly in order of effort:
- Borrow a Windows PC for 15 minutes — install **Sideloadly**, point it at the
  same unsigned IPA, sign in with your Apple ID, plug in the iPhone. Much
  simpler than the Linux path above.
- Rent a cheap cloud Mac by the hour (e.g. MacinCloud) just long enough to
  open Xcode, run the app on your device directly, and/or export a proper
  ad-hoc IPA — no local install needed.
- Ask me to keep this GitHub Actions workflow as the single source of the
  IPA, and revisit the signing step once you have temporary access to
  Windows/macOS.
