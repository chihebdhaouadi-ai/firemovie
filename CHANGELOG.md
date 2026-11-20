# Changelog

All notable changes to the FilmSage Flutter client. Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow
[Semantic Versioning](https://semver.org).

## [Unreleased]

### Added
- List page: comments look and work like a topic's, with replies, photos, the
  writer badge and the same comment box at the bottom; the heart works on your
  own list too.
- Topic page: Share, Edit, Delete, Save and Report moved into one ⋯ options menu.
- Notifications redesigned: All / Takes / Mentions / Requests tabs with unread
  counts, Friend requests / New / Earlier sections, a badge for each kind, how
  long ago, unread dots, Mark all read, and Accept ("You're now friends") or
  Decline with Undo. Opening the screen no longer marks everything read.
- Inbox: chat with friends one-to-one, in groups and in private topics, with a
  group rail, search, unread filter and a chat screen (polling, no push yet).
- Friends' stories on Home: each friend's recent takes and comments as story circles,
  with a full-screen viewer; the row folds into a small stack as you scroll.
- Project documentation: README, AGENTS.md, CONTRIBUTING.md, `docs/` (architecture,
  features, screens, testing, tech debt).
- GitHub issue and pull request templates; CI runs analyze and tests on pushes and PRs.
- Debate flow (client only), angel bird helper, create topic screen, review and topic
  detail screens, comment threads, take translation, avatar frames, Lottie badges.
- Latest articles and upcoming films sections on Home; guest browsing.
- Search page browse menu (before typing): top 100 takes, most popular films, browse by
  year, streaming service, genre, country and language, takes by kind, and placeholder FilmSage info pages.
- Bundled fonts (Space Grotesk, Inter, Space Mono, Pangram Sans, Bebas Neue).
- Film page: real Watched / Watchlist, Suggest to a friend, up to 3 feelings with live
  audience counts, sharing a take, real takes and friends' activity (demo content removed).
- Film detail: working Cast & crew tab, Where to watch grouped by Stream / Rent / Buy with
  logos and prices, and a play button that opens the trailer.

### Changed
- Film page reactions and takes redesign (#14): every feeling has its own colour and animated
  icon, feelings are picked in a sheet of tiles (animated bars when empty), the audience is a bar of each feeling's share, and
  "What people said" groups takes per person on a thread, shows each person's
  feelings (up to 3) and opens the take page from each card, with a "Share your take" button.
  Sections share one look (title outside a rounded card) and fill the width.
- Login screen redesign with social auth buttons (buttons not wired yet).
- Film pages share a hero header.
- Clearing the search field returns to recent searches and the browse menu instead of
  the "Keep typing" prompt.
- Film detail back button sits below the status bar instead of over the clock.
- Home lists and Angel Bird open the same film page as search and browse; the Articles
  tab on the film page is gone.

## [0.1.0] — baseline

First tracked state of the app, as published on `main` before this changelog existed.
