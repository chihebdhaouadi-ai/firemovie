# Known bugs and technical debt — Flutter client

Audited 2026-11-16. Each item should have a GitHub issue; link it here when it exists.

## Security

- **Hardcoded API token in git history.** Early commits contained a DRF token
  (`2aa9f4…`) in `lib/home/...` pages. It is no longer in the code but stays in public
  history. Fix: delete or rotate that token on the production backend (Django admin →
  Tokens). History is intentionally not rewritten.
- Firebase web/iOS/Android API keys and `android/app/google-services.json` are committed.
  These are client identifiers, not secrets, but should be restricted by app/bundle ID and
  HTTP referrer in Google Cloud Console.

## Broken or fake behaviour

- Debate feature calls `/api/debates/invites/`, `/api/debates/<id>/` and
  `/api/debates/<id>/questions/`, which the backend does not provide.
- Google, Apple and Reddit sign-in buttons do nothing.
- `FakePointsGateway` is wired in production (`main.dart`), so points are always 0.

## Code health

- `flutter analyze`: 520 issues (1 error, 114 warnings, 405 infos). The error is in
  `test/features/find/film_detail_screen_test.dart:45` (a removed `reviewRepository`
  parameter). Most warnings come from legacy `lib/home/`.
- `lib/home/` is unreferenced legacy code (old `HomeBLoc`). Candidate for deletion in its
  own PR.
- Home lists still use legacy backend endpoints (`/api/film/get_wathced_list_movies` and
  friends, typos included) while newer code uses `/api/lists/`. Migrate and then retire the
  legacy routes on the backend.
- Firebase Auth, Firestore and Realtime Database packages are unused but pull a large Swift
  Package graph into iOS builds (slow builds; a corrupt clone of it broke an iOS build
  during this audit).
- Inconsistent feature folder conventions (`bloc/views` and `domain/presentation`).
- Package name `film_wise_mobile` and pubspec description "A new Flutter project." do not
  match the product name.
- Unused Lottie files: `assets/lottie/header_bell.json`, `assets/lottie/header_pulse.json`,
  `assets/arrow.json`. Duplicate SVGs named `* copy.svg` in `assets/`.
- `intl: any` is unpinned in `pubspec.yaml`.

## Tests

- 60 of 262 widget tests fail (see `docs/testing.md`), including login page and home
  golden tests. Golden images are platform-dependent, so they also differ between macOS and
  Linux CI.
- `test/widget_test.dart` uses `print`.

## UX

See "Visual issues seen in the run" in `docs/screens.md`.
