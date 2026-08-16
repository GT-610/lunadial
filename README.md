# LunaDial

[![CI](https://github.com/GT-610/lunadial/actions/workflows/ci.yml/badge.svg)](https://github.com/GT-610/lunadial/actions/workflows/ci.yml)

**LunaDial** is a free and open-source cross-platform clock built with Flutter. It is designed to turn older phones, spare displays, and desktop windows into friendly, dependable clocks without requiring high-end hardware.

Android is the primary target. Windows and Linux are first-class desktop targets, while macOS is supported on a best-effort basis. iOS is not currently a supported release target.

## Features

- Digital and analog clock modes with a calendar
- Responsive layouts for phones, tablets, and desktop windows
- 12-hour, 24-hour, seconds, second-hand, and leading-zero options
- Material You and system accent colors with a custom-color fallback
- Light, dark, and system theme modes
- Always-on display support and Android immersive mode
- Manual, scheduled, and system-following night display modes
- OLED burn-in protection through subtle periodic movement
- English and Simplified Chinese localization
- Durable local settings with serialized, replace-on-write persistence

The app is intended to remain smooth on modern low-end hardware and has been tested on devices around the Snapdragon 625 performance class.

## Supported Targets

| Platform | Status |
|---|---|
| Android | Primary target, Android 6.0 / API 23 or newer |
| Windows | Supported and release-built in development |
| Linux | Supported through CI builds |
| macOS | Best-effort support through CI builds |
| Web | Buildable, but not a primary release target |
| iOS | Not currently supported |

## Project Structure

- `lib/app`: bootstrap, application shell, theming, and app-wide effects
- `lib/features/clock`: clock domain logic, controllers, and presentation
- `lib/features/settings`: settings models, persistence, and UI
- `lib/shared`: app-specific shared helpers and error presentation
- `test`: unit and widget coverage for clock, settings, and platform behavior

LunaDial intentionally keeps its UI inside the main project and avoids depending on a general-purpose component library.

## Getting Started

### Prerequisites

- A current stable Flutter SDK
- Platform-specific Flutter tooling for the target you want to build
- Java 17 and the Android SDK for Android builds

### Install dependencies

```bash
flutter pub get
```

### Run checks

```bash
flutter analyze
flutter test
```

### Build Windows

```bash
flutter build windows --release
```

### Sign Android releases

Copy `android/key.properties.example` to `android/key.properties` and replace the placeholder values with the path and credentials for your release keystore. The real properties file and keystore files are ignored by Git.

```bash
flutter build appbundle --release
```

Without `android/key.properties`, Gradle can still compile an unsigned release artifact for verification, but it is not suitable for publishing.

### Regenerate launcher icons

The editable icon sources and 1024 px raster inputs are stored under `assets/icon`.

```bash
dart run flutter_launcher_icons
```

## Continuous Integration

GitHub Actions runs analysis and tests, then verifies Android, Linux, Windows, and macOS release builds. Platform-specific failures should be fixed before publishing a release.

## Roadmap

A standardized clock-face and theme extension model is planned, but the format will be designed only after more built-in themes provide real implementation experience.

## Contributing

Contributions are welcome. Prefer focused, reviewable pull requests, add tests for behavior changes, and keep platform-specific dependencies limited to features LunaDial actually uses.

## License

LunaDial is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
