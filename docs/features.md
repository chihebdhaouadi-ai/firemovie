# Feature inventory — Flutter client

Audited 2026-11-16. Status was decided from code, the backend's routes, and a live run on the
iPhone 16e simulator against the local backend. "Verified" means seen working in that run;
"Not verified" means code and backend route exist but the flow was not exercised.

Legend: ✅ implemented and verified · 🟡 partial or unverified · 🧪 mock / placeholder · 📝 planned, not implemented

## Accounts and session

| Feature | Status | Notes |
|---|---|---|
| Sign in with email + password | ✅ | `POST /api/account/login` returned 200 in the run. `lib/account/` |
| Create account | 🟡 | Form and `POST /api/account/register` exist; not exercised |
| Guest browsing | ✅ | Closing login (X) opens Home as a guest; signed-in sections show a sign-in prompt |
| Session restore on launch | ✅ | `AuthCubit.restore()` reads the token from `shared_preferences` before the first frame |
| Auto sign-out on HTTP 401 | 🟡 | `Session.onUnauthorized` wiring exists; not exercised |
| Continue with Google / Apple / Reddit | 🧪 | Buttons render, `onPressed: () {}` (`login.dart:864-868`). No OAuth anywhere |
| Language switch (en, fr, ar, ru) | 🟡 | `AppLocale` + ARB files; RTL for Arabic not reviewed |

## Home (`lib/features/home`)

| Feature | Status | Notes |
|---|---|---|
| FILMSAGE header with + and notifications bell | ✅ | |
| You tab: popular films, trending topics, popular takes | ✅ | `/api/films/popular/`, `/api/takes/topics/trending/` |
| Friends tab: friends' takes | ✅ | `/api/takes/friends/takes/` |
| Films tab: Top 5, Watched, Watchlist collections | ✅ | Loaded through **legacy** `/api/film/get_*` endpoints |
| Latest articles section | 🟡 | `/api/articles/` returned `[]` locally (staff articles + imdb232 news feed) |
| Upcoming films section | 🟡 | `/api/upcoming/` returned `[]` locally (staff-entered in Django admin) |
| Points / balance pill | 🧪 | `FakePointsGateway` always returns 0. Backend has no points endpoint |

## Explore and takes (`lib/features/film_reviews`, `home/views/explore_page.dart`)

| Feature | Status | Notes |
|---|---|---|
| Explore feed with filters (All, Conversations, Polls, Scenes, …) | ✅ | `/api/takes/explore/` |
| Poll voting | ✅ | Seen voted state ("Thanks for voting") |
| Take detail, comments, replies, comment stance | 🟡 | `/api/takes/takes/<id>/comments/` returned 200; posting not exercised |
| Like / dislike votes on takes and comments | 🟡 | Routes exist |
| Create topic (discussion, question, poll, scene, spoiler) | 🟡 | `create_topic_screen.dart` + `POST /api/takes/topics/` |
| Translate a take or comment | 🟡 | Needs `OPENROUTER_API_KEY` on the backend; disabled when empty |

## Films (`lib/features/find`, `overview`, `popular`)

| Feature | Status | Notes |
|---|---|---|
| Search films ("All films") with recent searches | ✅ | `/api/films/search` (RapidAPI / OMDb via backend) |
| Browse menu on the search page before typing: top 100 takes, most popular films, by year (2 steps), by streaming service, genre, country (streaming there) and original language (each 2 steps), takes by kind (polls, conversations, scenes, questions, hot takes), FilmSage info pages (placeholders) | 🟡 | `/api/films/browse/`, `/providers/`, `/genres/`, `/countries/` (Watchmode, needs `WATCHMODE_API_KEY` on the backend; posters from OMDb), `/api/takes/top/` |
| Film detail: hero header, overview, genres, runtime, director | ✅ | Verified on *Joker*; one film page for every entry point (home lists and Angel Bird now open it too) |
| Film page actions: Watched / Watchlist (saved to the lists API, roll back on failure), Suggest to a friend | ✅ | `/api/lists/…`; Suggest opens "Suggest a movie" with the film picked. Verified on *The Dark Knight Rises* |
| Feelings: pick up to 3 ("How did it make you feel?") straight from coloured chips (each feeling has its own gradient), audience % and a static bar of every feeling's share ([details](film-reactions-takes.md)) | ✅ | `PUT /api/takes/films/<id>/reaction/` with `reactions`, `GET …/summary/`. Icons instead of emoji (emoji draw as boxes on the iOS 26 simulator) |
| Film page takes: "What people said" grouped per person on a thread (top take, translate, vote chips, comments, two takes then "Show more"), "Share your take" sheet (one review each), friends' activity ([details](film-reactions-takes.md)) | ✅ | `/api/takes/films/<id>/takes/`, `…/friends/` |
| Add to Watched / Watchlist / Top 5 | 🟡 | Buttons render with state; toggling not exercised |
| Cast & crew tab: main cast (billing order) and key crew | ✅ | Watchmode via `/api/films/<id>/` (`cast`, `crew`); verified on *The Dark Knight Rises* |
| Where to watch, grouped Stream / Free / TV provider / Rent / Buy with logos and prices | ✅ | Watchmode sources (US) via `watch_providers`; verified on *The Dark Knight Rises* |
| Trailer (play button on the hero) | ✅ | Opens the Watchmode trailer link, or a YouTube search for "<title> <year> official trailer" when there is none (common on the free plan) |
| Activity from friends | ✅ | Empty state shown |
| Film reactions and takes on the film | 🟡 | `/api/takes/films/<id>/takes/` 200 |

## Social (`lib/features/social`)

| Feature | Status | Notes |
|---|---|---|
| Notifications list | ✅ | `/api/social/notifications` 200 |
| User search, friend requests (send/accept/decline/cancel) | 🟡 | Routes exist; not exercised |
| Suggest a film to friends | 🟡 | `POST /api/social/movie-suggestions` |
| Public profiles | ✅ | `/api/account/users/<id>` 200 |

## Profile and gamification (`lib/features/profile`, `leaderboard`)

| Feature | Status | Notes |
|---|---|---|
| Profile: avatar upload, bio, stats, level and XP bar | ✅ | Verified visually |
| Badges (Well argued, Changed my mind, Disagree but fair, Top critic, …) | ✅ | Lottie badges |
| Avatar frames unlocked by achievements, tap to equip | 🟡 | Rendered; equip not exercised |
| Leaderboard + "how it works" | 🟡 | `/api/takes/leaderboard/` |

## Experimental

| Feature | Status | Notes |
|---|---|---|
| Angel bird: hold 3 s anywhere to ask the bird; it offers pages | 🟡 | `lib/features/angel_bird`, widget-tested; not exercised |
| Debate: invite a friend, waiting room, quiz | 🧪 | Client only. Calls `/api/debates/…`, which **does not exist** on the backend |
| Onboarding screen | 🟡 | Route exists |
| News ticker | 🟡 | Depends on `/api/articles/` news feed |

## Planned, not implemented

| Feature | Notes |
|---|---|
| Reddit integration and synchronization | No code in either repo beyond a non-functional "Continue with Reddit" button |
| Social sign-in (Google, Apple) | No OAuth on client or backend |
| Points economy | `User.balance` exists on the backend, no API or client logic |
| Push notifications | None |
| Firebase Auth / Firestore / Realtime DB | Packages installed, never initialised |
