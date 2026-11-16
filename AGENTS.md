# AGENTS.md — instructions for AI coding agents

Applies to Claude Code, Codex, Cursor and any other agent working in this repository.
Humans should follow it too.

## Project

FilmSage Flutter client (`film_wise_mobile`). Backend: `chihebdhaouadi-ai/firemovie-backend`.
Read first: `README.md`, `docs/architecture.md`, `docs/features.md`, `docs/tech-debt.md`.

## Source of truth

- **GitHub** owns code, issues, pull requests, development status and releases.
- **Notion (FilmSage HQ)** owns product specs, design docs, screenshots and progress reports.
  Do not track tasks in Notion. Link issues and PRs from Notion pages instead.

## Workflow (required)

1. Start from a GitHub issue. If none exists, create one (bug / feature / improvement
   template) before writing code.
2. Branch from `main`: `feature/<issue#>-short-name`, `fix/<issue#>-…`, `chore/<issue#>-…`,
   `docs/<issue#>-…`. Never commit to `main` directly.
3. Keep changes scoped to the issue. Do not refactor or restyle working code that the issue
   does not touch.
4. Before every commit run:
   ```bash
   flutter analyze
   flutter test
   ```
   Do not add new analyzer errors or warnings. Do not make the failing-test count worse
   (baseline in `docs/testing.md`). If you fix tests, update the baseline.
5. Open a PR with the template. Put `Closes #<issue>` in the body. CI must run.
6. Update docs in the same PR when behaviour, structure, endpoints or screens change:
   `docs/features.md`, `docs/screens.md`, `docs/architecture.md`, `CHANGELOG.md`
   (Unreleased section). Flag Notion pages that need updating in the PR description.

## Rules

- Never commit secrets, tokens, `.env` files, keystores or signing files. The app has no
  runtime secrets; configuration goes through `--dart-define` (see `.env.example`).
- Never claim a feature works without running it. Say "not verified" when you could not.
- Never force-push shared branches or rewrite history without the owner's approval.
- Ask before deleting files, dependencies or features, including the legacy `lib/home/`.
- Do not edit generated files by hand: `lib/l10n/app_localizations*.dart` (run
  `flutter gen-l10n`), `lib/firebase_options.dart`, platform build files.
- All user-facing text goes through ARB files (`lib/l10n/app_en.arb` first, then fr, ar, ru).

## Code conventions

- Feature-first: `lib/features/<feature>/{data,domain,bloc|presentation,views}`. Match the
  structure already used inside the feature.
- State: `flutter_bloc`. `AuthCubit` is the only writer of `Session.token`.
- HTTP: use `ApiClient` (`lib/features/find/data/api_client.dart`) and `ApiConfig.baseUrl`.
  Never hardcode hosts.
- Repositories expose an interface plus `Api*` and `Fake*` implementations; tests use the
  fakes or `mocktail`.
- Theme values come from `lib/core/theme/app_theme.dart` and `lib/core/widgets/`.
- Tests mirror `lib/` under `test/`.

## Running locally

```bash
# backend (other repo)
cd ../firemovie-backend && venv/bin/python manage.py runserver 127.0.0.1:8000
# app
flutter run -d "iPhone 16e"
```

## Repo-specific agents

`.claude/agents/` defines project subagents (teamlead, dart-architect, ui-motion-engineer,
flutter-tester, app-runner). They follow this file.
