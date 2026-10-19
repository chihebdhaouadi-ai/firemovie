# Film Wise: feature inventory

Source: a read of `lib/` (Flutter) and the Django apps `accounts`, `films`, `reviews`, `social`.
Status key: **works** = wired to the real API and covered by tests. **needs key** = works once the server has a RapidAPI key. **not advertised** = placeholder or design only; kept out of the page.

Themes are ordered by what a new user needs first.

## 1. Build your film lists

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Top 5 favourites | Show the five films that define your taste, in order. | `lib/features/home/views/widgets/top5_row.dart`; API `/api/lists/top5/` | works | `assets/screens/home.png` |
| Watched list | Keep a record of everything you have seen. | `lib/features/home/views/widgets/film_section.dart`; `/api/lists/watched/` | works | `assets/screens/home.png` |
| Watchlist | Save films to watch next so you never lose them. | `/api/lists/watchlist/` | works | `assets/screens/home.png` |
| Add and remove films | Change any list in one tap. | `film_tile.dart`, `add_tile.dart`, `quick_actions_bar.dart` | works | `assets/screens/home-add.png` |

## 2. Find any film

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Film search | Type a title and find it in seconds. | `lib/features/find/views/find_film_screen.dart`; `GET /api/films/search` (`films/movie_source.py`) | needs key | `assets/screens/find.png` |
| Recent searches | Pick up where you left off. | `find/data/recent_searches_store.dart`, `widgets/recent_searches.dart` | works | `assets/screens/find-recent.png` |
| Film details | Read the synopsis, runtime, genres, director and poster before you commit. | `lib/features/find/views/film_detail_screen.dart`; `GET /api/films/<id>/` | needs key | `assets/screens/film-detail.png` |
| Add from search results | Add a result straight to a list without leaving search. | `find/views/widgets/add_button.dart`, `result_actions.dart` | works | `assets/screens/find.png` |

## 3. Make it yours

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Onboarding setup | Set up your profile on day one: photo, cover and bio. | `lib/features/onboarding/views/onboarding_screen.dart`; `PATCH /api/account/profile` (multipart) | works | `assets/screens/onboarding.png` |
| Profile page | See your name, bio and friend count in one place. | `lib/features/profile/views/profile_screen.dart`; `GET /api/account/profile` | works | `assets/screens/profile.png` |

Not advertised: the profile tag, rewards and achievement badges (placeholder data in `profile_placeholders.dart`).

## 4. Connect with friends

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Find people | Search by name and find your friends. | `lib/features/social/views/user_search_screen.dart`; `GET /api/social/users/search` | works | `assets/screens/friends-search.png` |
| Friend requests | Send, accept, decline or cancel a request. | `social/data/social_repository.dart`; `POST /api/social/friend-requests` and `/accept`, `/decline`, `/cancel` | works | `assets/screens/friends-search.png` |
| Friends list | Keep your circle in one list. | `GET /api/social/me/connections` | works | `assets/screens/friends.png` |
| Notifications | Know when a friend asks to connect or sends you a film, and mark them read. | `lib/features/social/views/notifications_screen.dart`; `GET /api/social/notifications`, `POST /api/social/notifications/read` | works | `assets/screens/notifications.png` |

Not advertised: the friend-activity feed on the film overview (placeholder names).

## 5. Recommend films to friends

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Send a film to a friend | Recommend a film with a short note and a poster. | `lib/features/social/views/movie_suggestion_screen.dart`; `POST /api/social/movie-suggestions` | works | `assets/screens/suggest.png` |
| Suggestions in your inbox | See films your friends sent you, next to their note. | `notifications_screen.dart`; `kind = movie_suggestion` | works | `assets/screens/notifications.png` |

## 6. Your account, everywhere

| Feature | User benefit | Where it lives | Status | Screenshot |
|---|---|---|---|---|
| Create account and sign in | Start in under a minute and get back to your lists. | `lib/account/views/pages/login.dart`, `lib/account/blocs/login_bloc.dart`; `POST /api/account/register`, `/api/account/login` | works | `assets/screens/login.png` |
| Lists follow your account | Your lists are saved on the server, not just on one phone. | `films/list_urls.py`, `films/views.py` | works | `assets/screens/home.png` |

## Not on the page (design only or placeholder)

- Points and the "Generate" recommendation button: `FakeRecommendationGateway` only. No backend.
- Where to watch (streaming providers): the backend response never includes providers, so the app always shows "No streaming providers found".
- Popular friends list: only in the old home screen.
- Film reviews: backend endpoints exist but the new app never submits a review. Reviews in the overview are placeholders.
- Cast, crew and production details on the overview: placeholders.

## Open items

- Film search and details need a RapidAPI key on the server. Without it they return an error, and the screenshots for section 2 must wait for a key.
- Screenshots are captured from the iOS simulator against an isolated demo backend. Nothing in this file has been checked end-to-end on a device yet.
