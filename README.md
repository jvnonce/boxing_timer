# Boxing Timer

Cross-platform round timer for boxing, MMA, and kickboxing training. Configure rounds, work and rest intervals, start delay, and audible warnings; run sessions with clear phase colors and optional background status on mobile.

## Features

- Preset and custom match profiles (round count, work/rest, delay, warning thresholds)
- Run flow: prepare → work → rest → next round, with pause, stop, and manual phase skips
- Warning cues (sound only; UI stays on work/rest phases)
- Local persistence via SharedPreferences
- Localization: English, Russian, Spanish
- Optional foreground notification on Android/iOS when notification permission is granted
- Keep-screen-on while running (mobile)

## Supported platforms

| Platform | Status |
|----------|--------|
| Android | Full (timer, sounds, wakelock, background notification with permission) |
| iOS | Timer, sounds, wakelock; background service limited vs Android |
| Web | Timer UI and sounds (browser autoplay rules may require a user gesture first) |
| Linux / macOS / Windows | Timer and sounds; no mobile background service |

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible with Dart `^3.12.2` (see `pubspec.yaml`)
- For mobile builds: Android SDK and/or Xcode as usual for Flutter

## Getting started

```bash
git clone git@github.com:jvnonce/boxing_timer.git
cd boxing_timer
flutter pub get
flutter run
```

Examples:

```bash
flutter run -d chrome          # web
flutter run -d linux             # Linux desktop
flutter build apk --release      # Android APK
```

Generated localization files are produced by Flutter (`flutter gen-l10n` runs via `generate: true` in `pubspec.yaml`).

## Project layout

- `lib/` — application code (UI, BLoC, models, services)
- `assets/svg/` — match icons
- `assets/sounds/` — bell and warning sounds
- `lib/l10n/` — ARB localization sources

## License

This project is licensed under the [MIT License](LICENSE).

Dependencies are distributed under their own licenses (mostly BSD-3-Clause and MIT). To list them:

```bash
flutter pub licenses
```

Bundled icons and sound files are included for use with this app; verify terms if you replace assets with third-party media.

## Repository

- GitHub: [github.com/jvnonce/boxing_timer](https://github.com/jvnonce/boxing_timer)
