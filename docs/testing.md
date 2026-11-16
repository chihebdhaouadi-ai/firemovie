# Testing

## How to run

```bash
flutter analyze
flutter test                         # all tests, about 11 minutes locally
flutter test test/features/find      # one folder
```

Tests mirror `lib/` under `test/`. Use the `Fake*` repositories or `mocktail`; never hit
the network.

## Baseline (2026-11-16, Flutter 3.47.1, macOS)

Do not make these numbers worse. When you fix tests, update this table in the same PR.

| Check | Result |
|---|---|
| `flutter analyze` | 516 issues: **0 errors**, 114 warnings, 402 infos |
| `flutter test` | **225 passed, 59 failed**, all files compile |

### Failing tests by file

| File | Failures |
|---|---|
| `test/features/home/zz_probe_home_gated_test.dart` | 21 (includes golden at 360x800) |
| `test/features/profile/profile_screen_test.dart` | 11 |
| `test/features/film_reviews/review_section_test.dart` | 9 |
| `test/account/login_page_test.dart` | 4 |
| `test/features/social/social_screens_test.dart` | 3 |
| `test/features/home/explore_tab_test.dart` | 3 |
| `test/features/angel_bird/angel_bird_host_test.dart` | 3 |
| `test/features/debate/debate_flow_test.dart` | 2 |
| `test/features/angel_bird/review_hold_test.dart` | 2 |
| `test/features/overview/movie_overview_screen_test.dart` | 1 |
| `test/features/home/home_screen_test.dart` | 1 |

### Causes found

- **`pumpAndSettle timed out`** (28 occurrences): screens now run looping Lottie or
  repeating animations, so the tree never settles. Use `pump(duration)` or disable
  animations in tests.
- **Stale finders** after the redesigns: e.g. `FilledButton` ancestors of "Tap to …" and
  "Yes, …", "react" and "let's debate" buttons, duplicate "FILMSAGE" / "Changed my mind"
  texts.
- **`UnimplementedError` in `TrendingTopicsSection`**: a test fake does not implement a
  method the section now calls.
- **`RenderFlex overflowed by 27 pixels on the right`** (5 occurrences): a real layout
  overflow on small screens. Worth fixing in the app, not only the test.
- **Golden** at 360x800 differs; goldens are platform-dependent and will also differ on the
  Linux CI runner.

## Backend

See the backend repo: 240 tests, all passing on 2026-11-16.

## CI

`.github/workflows/tests.yml` runs `flutter analyze --no-fatal-infos --no-fatal-warnings`
and `flutter test` on Ubuntu for every push to `main` and every pull request. It is red
until the baseline above is fixed, so it is not yet a required check on `main`.
