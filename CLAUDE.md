# Pocket Chess

Flutter chess app using Riverpod + GoRouter.

## Architecture

```
lib/
  ai/           - AI strategies (minimax, stockfish) + providers
  core/         - App-wide config: colors, settings, piece themes
  engine/       - Chess engine abstraction + implementation
  models/       - Domain models (pure Dart, no Flutter)
  repositories/ - Data persistence + providers
  router/       - GoRouter setup + Routes constants
  ui/
    <feature>/
      - controller(s)
      - screen(s)
      - widgets/    (feature-specific)
    widgets/        (shared across features)
```

## Rules

- Co-locate providers with their feature, not in a central file.
- `ui/<feature>/widgets/` for feature-specific widgets; `ui/widgets/` for shared.
- Route paths live in `router/routes.dart` as `Routes.*` constants. Never hardcode route strings.
- Models are pure Dart with no Flutter imports.
- `core/` is for app-wide config only (themes, colors, settings).

## Commands

- `flutter analyze` - lint/type check
- `flutter test` - run all tests
