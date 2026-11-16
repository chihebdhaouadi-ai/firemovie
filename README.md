# FilmSage — mobile app

FilmSage is a social film app. People keep a Top 5, a watched list and a watchlist, post
"takes" (reviews, discussions, polls, scene and spoiler posts) about films, react and vote,
follow friends, suggest films to each other and climb a reputation leaderboard.

This repository is the **Flutter client** (iOS, Android, web, macOS). The Django REST
backend lives in [firemovie-backend](https://github.com/chihebdhaouadi-ai/firemovie-backend).

> The Dart package is still called `film_wise_mobile` and the repository `firemovie`.
> Both are historical names for FilmSage. Do not rename them without a dedicated issue.

## Status

Active development. See [docs/features.md](docs/features.md) for what is built, partial,
mocked or planned, and [docs/tech-debt.md](docs/tech-debt.md) for known problems.
Product and design documentation lives in Notion (FilmSage HQ); tasks live in
[GitHub Issues](https://github.com/chihebdhaouadi-ai/firemovie/issues).

## Quick start

Requirements: Flutter stable (3.47 or later; Dart SDK >= 3.2.3), Xcode for iOS, Android
Studio for Android. Run the backend locally first (see the backend README).

```bash
flutter pub get
flutter run -d "iPhone 16e"          # any simulator or device
```

Debug builds talk to `http://127.0.0.1:8000`. Release builds talk to the hosted Heroku
backend. Override either with a compile-time define:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000   # physical device on your LAN
```

There are no runtime secrets in the app. See [.env.example](.env.example) for the
defines it accepts.

## Checks

```bash
flutter analyze
flutter test
```

CI runs both on every push and pull request (`.github/workflows/tests.yml`).
Current baseline: see [docs/testing.md](docs/testing.md).

## Project layout

```
lib/
  main.dart               App entry, routes, auth restore
  core/                   API config, session/auth, theme, shared widgets
  account/                Login and sign-up (Bloc)
  features/<feature>/     Feature-first modules: data/ domain/ presentation|views/ bloc/
  home/                   LEGACY home screen, unreferenced (see tech-debt)
  l10n/                   ARB files (en, fr, ar, ru) and generated localizations
assets/                   Images, SVG icons, Lottie animations, fonts
test/                     Widget, bloc and repository tests, mirroring lib/
landing/                  Static marketing landing page
docs/                     Architecture, features, screens, testing, tech debt
```

Read [docs/architecture.md](docs/architecture.md) before changing structure.

## Contributing

Work happens on feature branches through pull requests linked to issues.
See [CONTRIBUTING.md](CONTRIBUTING.md). AI coding agents must also read [AGENTS.md](AGENTS.md).

## License

MIT, see [LICENSE](LICENSE). Bundled fonts keep their own licenses (`assets/fonts/OFL-*.txt`).
