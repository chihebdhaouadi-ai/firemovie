# Screens and user flows

Audited 2026-11-16 on iPhone 16e (debug build, local backend). Screenshots live in Notion
(FilmSage HQ → Flutter Documentation). They are kept out of this public repo because they
show real account data.

## Main flow

```
Launch ─► Login ──sign in──► Home (You tab)
            └──X (close)──► Home as guest
Home ─ bottom nav ─► Explore │ SAGE menu (Explore, Films) │ Search ("All films") │ Profile
Any poster ─► Film detail ─► takes, where to watch, add to lists
Any take ─► Take / topic detail ─► comments, votes, translate
```

## Screen reference

| Screen | File | Entry | Key interactions | Loading / empty / error |
|---|---|---|---|---|
| Login / Sign up | `account/views/pages/login.dart` | App start, sign-in prompts | Sign in, switch to sign up, show/hide password, social buttons (no-op), close (X) | Submit shows a spinner; field validation; server error message |
| Home | `features/home/views/home_screen.dart` | `/`, `/home` | Tabs You / Friends / Films, + (create topic), bell (notifications) | Shimmer placeholders; guests see a "Sign in to see your films and friends" card |
| Explore | `features/home/views/explore_page.dart` | Nav bar compass, SAGE menu | Filter chips, open take, vote in polls, + create | "No replies yet / Be the first to respond" |
| Feed list | `features/home/views/feed_list_screen.dart` | "Popular takes" list toggle | Scroll, open take | |
| Create topic | `features/create_topic/views/create_topic_screen.dart` | Header +, Explore + | Choose type, pick film, write, poll options, spoiler flag | Validation errors |
| All films (search) | `features/find/views/find_film_screen.dart` | Nav bar search, `/find` | Type a title, open result, recent searches; browse menu (`features/browse/views/browse_menu.dart`) while the field is empty | "No recent searches yet." |
| Browse films | `features/browse/views/browse_films_screen.dart` | Browse menu: Most popular films, a year, a streaming service, a genre, a country, a language | Poster grid, infinite scroll, open film detail | "No films here yet."; error with retry |
| Pick a year / Pick a streaming service | `features/browse/views/browse_years_screen.dart`, `streaming_services_screen.dart` | Browse menu | Step 1 of browse by year / service | "No streaming services available." |
| Pick a genre / country / language | `features/browse/views/browse_pick_screen.dart` | Browse menu | Step 1 of browse by genre, country (films streaming there) or language | "Nothing to pick from right now." |
| Browse takes | `features/browse/views/browse_takes_screen.dart` | Browse menu: Top 100 takes, Polls, Conversations, Scenes, Questions, Hot takes | Take cards | "Nothing posted here yet." |
| Info page | `features/browse/views/info_page_screen.dart` | Browse menu: New here?, Social media, Follow us, Gifts, Contact, Terms | Placeholder | "Coming soon" |
| Film detail | `features/find/views/film_detail_screen.dart` | Any poster | Watched, Watchlist, Suggest, trailer (in-app pop-up player), feelings (up to 3, tap chips on the page), audience bar, friends' activity, "What people said" (takes grouped per person) with a "Share your take" sheet; tabs Overview / Cast & crew / Where to watch (Articles tab removed) | Backdrop/poster placeholders; "No cast and crew information yet."; "No streaming providers found"; "No activity from your friends yet." |
| Movie overview | `features/overview/views/movie_overview_screen.dart` | Angel bird, overview panel | Read synopsis panels | |
| Take detail | `features/film_reviews/presentation/review_detail_screen.dart` | Take card | Comment, reply, vote, translate | |
| Topic detail | `features/film_reviews/presentation/topic_detail_screen.dart` | Trending topic card | Vote like/dislike, comment | |
| Profile | `features/profile/views/profile_screen.dart` | Nav bar avatar | Change avatar, edit bio, badges, frames (tap to equip), search, leaderboard, notifications, sign out | |
| Leaderboard | `features/leaderboard/views/leaderboard_screen.dart` | Profile trophy | View ranks, "how it works" | |
| Notifications | `features/social/views/notifications_screen.dart` | Bell | Accept or decline friend requests, open suggestions | Empty state |
| User search | `features/social/views/user_search_screen.dart` | Profile search | Find users, send friend request | |
| Suggest a film | `features/social/views/movie_suggestion_screen.dart` | Film detail | Pick friends, add comment, send | |
| Debate waiting / quiz | `features/debate/presentation/` | Take card "debate" action | Invite, wait, answer questions | Fails against the real backend (no `/api/debates/`) |
| Onboarding | `features/onboarding/views/onboarding_screen.dart` | Named route | | |
| Angel bird overlay | `features/angel_bird/angel_bird_host.dart` | Hold 3 s anywhere | Question bubble, options, loading, empty, failed stages | Has explicit `loading`, `empty`, `failed` stages |

## Visual issues seen in the run

- Home You tab: the "Popular Films" heading and posters under the tab bar render blurred
  while the page is at rest (scroll-exit effect looks applied at offset 0).
- Profile header shows two identical trophy buttons side by side.
- SAGE radial menu labels ("Films") overlap the content underneath; there is no scrim
  behind the labels, only a dim.
- Film detail: the floating poster overlaps the right side of the title block; long
  director lines wrap under it.
- Mixed typefaces in one screen (Space Mono for badge names and the trailer button, Space
  Grotesk and Inter elsewhere) without a clear rule.
