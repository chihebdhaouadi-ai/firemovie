# Architecture — Flutter client

Audited 2026-11-16 on branch `feature/guest-browsing`. Update this file whenever structure,
state management or data flow changes.

## System overview

```
Flutter app (this repo)  ──HTTPS / JSON, DRF token──►  Django REST API (firemovie-backend)
                                                         ├─ PostgreSQL (Heroku) / SQLite (local)
                                                         ├─ S3 (Bucketeer) for uploaded media
                                                         └─ RapidAPI (online-movie-database, imdb232), OMDb,
                                                            OpenRouter (translation)
Firebase Hosting  ──serves──►  Flutter web build (firemovies-d3c6b.web.app)
```

The app never talks to third-party movie APIs directly; every external call goes through
the backend, which holds the keys.

## Layers

Feature-first folders under `lib/features/<feature>/`:

| Folder | Holds |
|---|---|
| `data/` | Repositories (`Api*Repository` talking HTTP, `Fake*` for tests), parsers, DTOs |
| `domain/` | Plain immutable models and enums (e.g. `film_reviews/domain/take_tag.dart`) |
| `bloc/` or `presentation/state/` | Blocs and Cubits (`flutter_bloc` 9) |
| `views/` or `presentation/` | Screens and widgets |

Naming is not yet uniform: newer features (`film_reviews`, `debate`) use
`domain/` + `presentation/`, older ones (`home`, `find`) use `bloc/` + `views/`.
Follow the pattern already used inside the feature you touch.

## State management

- **flutter_bloc** everywhere. `AuthCubit` (`lib/core/auth/`) is the single source of truth
  for signed-in state; it mirrors the token into the static `Session` that `ApiConfig`
  reads. Only `AuthCubit` may write `Session.token`.
- `HomeBloc` (`lib/features/home/bloc/`) drives the home tabs. It is created per route in
  `main.dart` with `ApiHomeRepository` and `FakePointsGateway`.
- Feature cubits are created where their screen is pushed.

## Networking

- `ApiConfig.baseUrl` (`lib/core/api_config.dart`): `--dart-define=API_BASE_URL` wins;
  debug falls back to `http://127.0.0.1:8000`, release to the Heroku URL.
- `ApiClient` (`lib/features/find/data/api_client.dart`) wraps `package:http`, adds the
  `Authorization: Token <key>` header, and reports HTTP 401 to `Session.reportUnauthorized`
  so `AuthCubit` drops back to guest.
- The app uses two generations of backend endpoints:
  - Legacy `/api/film/get_*` and `add_*` (home lists).
  - New REST `/api/lists/`, `/api/films/`, `/api/takes/`, `/api/social/`, `/api/articles/`,
    `/api/upcoming/`, `/api/account/`.
  The full endpoint list is in the backend repo: `docs/api.md`.

## Navigation

Named routes in `main.dart`: `/` and `/home` (home), login, onboarding and `/find`.
Everything else is pushed imperatively with `MaterialPageRoute`. The app opens on the login
route. Closing it (X) leaves a guest on Home. `AngelBirdHost` wraps every route through
`MaterialApp.builder` so the hold-to-ask bird can appear anywhere.

Bottom navigation (`lib/core/widgets/sage_nav_bar/`): Home, Explore, SAGE (radial menu:
Explore, Films), Search (pushes the full-screen "All films" search) and Profile.

## Persistence on device

`shared_preferences` stores the auth token (`SharedPrefsAuthTokenStore`), the chosen locale
(`AppLocale`) and recent searches. There is no local database.

## Localization

`flutter gen-l10n` with ARB files in `lib/l10n/`: English (template), French, Arabic and
Russian. All user-facing strings go through `context.l10n`.

## Theme and design system

`lib/core/theme/app_theme.dart` defines a single dark theme. Shared "game-like" widgets
live in `lib/core/widgets/` (`game_button`, `luxe_chip`, `avatar_frame`, `sage_nav_bar`).
Fonts: Space Grotesk, Inter, Space Mono, Pangram Sans and Bebas Neue (bundled in
`assets/fonts/`).

## Animations

`lottie` for the angel bird (`assets/angel_bird.json`), loading (`film_loading.json`),
`flamefire.json`, header sparkles/XP star/arrow, profile frames (`assets/lottie/frame_*.json`)
and badges (`assets/lottie/badge_*.json`). `header_bell.json`, `header_pulse.json` and
`assets/arrow.json` are bundled but not referenced from current code.

## Firebase

`firebase_core`, `firebase_auth`, `firebase_database` and `cloud_firestore` are dependencies
and `lib/firebase_options.dart` is generated, but **`Firebase.initializeApp` is never called**.
Firebase is used only for **Hosting** of the web build. The SDKs add a large Swift Package
graph to iOS builds. Tracked as tech debt.

## Legacy code

`lib/home/` (`HomeBLoc`, `Top_5_moviesState`, old pages) is not imported by anything
outside itself, and is the source of most analyzer warnings. Do not extend it.
