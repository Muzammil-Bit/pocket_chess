# Pocket Chess

Pocket Chess is a polished Flutter chess app for quick games, local pass-and-play matches, and engine battles. It ships with multiple game modes, configurable AI opponents, persistent game history, time controls, and a large catalog of chess piece themes.

## Features

- Human vs AI, local two-player, and AI vs AI modes
- Configurable AI difficulty with `Minimax` everywhere and `Stockfish` support on Android and iOS
- Time-control presets from bullet to classical
- Persistent game history with saved move lists and final positions
- Piece-theme picker with a large built-in asset catalog
- Light, dark, and system appearance modes
- Flutter app targets for Android, iOS, web, macOS, Linux, and Windows

## Tech Stack

- Flutter
- Riverpod
- GoRouter
- `chess` and `dartchess` for move generation and game rules
- `chessground` for board interaction
- `stockfish` for stronger mobile AI play
- JSON file storage plus `shared_preferences` for local persistence

## Getting Started

### Prerequisites

- Flutter `stable`
- Dart SDK compatible with the version declared in [pubspec.yaml](/Users/muzammil/Documents/playground/chess/pubspec.yaml)

### Install

```bash
flutter pub get
```

### Run

```bash
flutter run
```

To run a specific platform target:

```bash
flutter run -d chrome
flutter run -d macos
flutter run -d android
```

## AI Support Notes

- `Minimax` is available on every platform.
- `Stockfish` is currently enabled only on Android and iOS.
- On unsupported platforms, any Stockfish selection is normalized back to Minimax automatically.

## Testing

Run the test suite with:

```bash
flutter test
```

Current tests cover app navigation, game controller behavior, saved-game serialization, and piece-theme discovery.

## Project Structure

```text
lib/
  ai/             AI strategies and Stockfish integration
  core/           app settings, colors, and piece-theme catalog
  engine/         chess engine abstraction and implementation
  models/         domain models for games, moves, settings, and history
  repositories/   saved-game persistence
  router/         app routing
  ui/             screens and widgets
test/             widget and unit tests
assets/pieces/    bundled chess piece themes and per-theme licenses
```

## Persistence

- App settings are stored with `shared_preferences`
- Game history is stored locally as JSON in the app documents directory
- History is capped to the most recent 100 saved games

## Open Source Notes

The project code is licensed under the MIT License. See [LICENSE](/Users/muzammil/Documents/playground/chess/LICENSE).

This repository includes third-party chess piece assets under `assets/pieces/`. Many themes include their own `license.md` or `license.txt` files. Those asset licenses remain in effect for the bundled piece sets, so keep those notices intact when redistributing the app or repackaging the assets.

## Roadmap Ideas

- Online multiplayer
- PGN export and import
- Stronger analysis tools
- Clocks and post-game insights
- Better contributor docs and release notes

## Contributing

Issues and pull requests are welcome. For larger changes, opening an issue first is a good way to align on scope and direction.
