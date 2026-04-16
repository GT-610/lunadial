# LunaDial

**LunaDial** is a cross-platform, free and open-source clock application built with Flutter. The project started from a simple goal: turning older phones and spare devices into focused desk clocks, and it is now being reorganized so the same codebase can keep growing across mobile, desktop and web.

## Features

- Digital and analog clock modes
- Calendar panel for analog mode
- Theme color, theme mode and language settings
- Optional keep-screen-on behavior for dedicated clock devices
- Cross-platform Flutter targets: Android, iOS, macOS, Linux, Windows and web

## Project Status

This repository is in an active cleanup/refactor phase. The current focus is:

- Stabilize the app architecture for future features
- Reuse shared UI and animation primitives from the local `fl_lib` package
- Keep the current clock experience working while making the codebase easier to extend

## Structure

- `lib/app`: app bootstrap, shell and app-wide effects
- `lib/features/clock`: clock domain logic and presentation
- `lib/features/settings`: settings models, persistence and UI
- `lib/shared`: shared app-specific presentation helpers
- `packages/fl_lib`: local shared Flutter library used for selective UI reuse

## Using `fl_lib`

This project includes a local `fl_lib` package under `packages/fl_lib`. It is treated as a local collaboration library and is currently consumed through a path dependency. LunaDial only reuses the parts that have a low integration cost and clear value for this app, such as shared card and animation widgets.

If `fl_lib` changes, verify the LunaDial app still analyzes and tests cleanly before committing.

## Getting Started

### Prerequisites

- Flutter SDK
- Platform-specific Flutter tooling for the targets you want to run

### Install dependencies

```bash
flutter pub get
```

### Run checks

```bash
flutter analyze
flutter test
```

## Roadmap

- Improve adaptive layouts for phone, tablet and desktop use cases
- Expand clock-specific UX without coupling new features into one screen file
- Continue consolidating reusable UI into shared components where it makes sense

## Contributing

Contributions are welcome. Please prefer small, reviewable pull requests and keep architecture changes aligned with the feature-based layout above.

## License

This project is licensed under GNU GPL v3 - see the [LICENSE](LICENSE) file for details.
