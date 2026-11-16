# Film Wise: landing page copy

Every word on the landing page lives here. `index.html` must match this file.
Only features marked working in `FEATURES.md` are described. No numbers, ratings, reviews or testimonials are invented.

Brand name: **Film Wise** (one name everywhere).

---

## Document

- **Title:** Film Wise: track the films you love, share them with friends
- **Description:** Film Wise helps you build your Top 5, a watched list and a watchlist, search any film and recommend films to your friends.
- **OG title:** Film Wise: track the films you love
- **OG description:** Build your Top 5, keep your watched list and watchlist, and recommend films to friends.

## Intro (plays once per session, skippable)

- Kicker: Media GCP Production presents
- Title: Film Wise
- Skip button: Skip intro

## Header

- Logo (alt): Film Wise
- Nav: Features · How it works · FAQ
- Button: Get the app
- Menu button (phone widths only): Menu

## Hero

- Eyebrow: Your film life, in one app
- H1: Track every film you love, and share the ones that matter.
- Button 1 (primary): Get the app
- Button 2 (ghost): See what it does
- Screenshot caption: Your Top 5, watched list and watchlist on the home screen.

## Headline benefits (4)

1. **Your five favourites, in order**
   Pin the films that define your taste and keep them at the top of your home screen.
2. **Lists that stay with you**
   Your watched films and watchlist are saved to your account, so they follow you to any phone where you sign in.
3. **Find any film fast**
   Search by title, open the details and add a film to a list without leaving search.
4. **Friends who share your taste**
   Find friends, send a film with a note, and see what they send you.

## Feature sections

### 1. Build your film lists  (id: `lists`)

- Benefit: Three lists cover the whole journey, from your first favourite to your next watch.
- Bullets:
  - **Top 5:** pin your five favourite films, in order.
  - **Watched:** keep a record of everything you have seen.
  - **Watchlist:** save the films you want to see next.
  - Add or remove a film from any list in one tap.
- Screenshot: Home screen with the three lists. Caption: Your lists, one tap away.

### 2. Find any film  (id: `find`)

- Benefit: Search by title and get to the film you want in seconds.
- Bullets:
  - Search films by title.
  - Reopen your recent searches.
  - Read the synopsis, runtime, genres, director and poster before you decide.
  - Add a result to a list straight from search.
- Screenshot: Search results. Caption: Search, check, add.
- Launch condition: film search and details need the film data key on the server.

### 3. Make it yours  (id: `profile`)

- Benefit: Set up your profile on day one so friends recognise you.
- Bullets:
  - Add a photo, a cover image and a short bio during setup.
  - See your name, bio and friend count on your profile.
- Screenshot: Profile page. Caption: Your profile, your way.

### 4. Connect with friends  (id: `friends`)

- Benefit: Find the people you watch films with and keep your circle in one place.
- Bullets:
  - Search people by name.
  - Send, accept, decline or cancel friend requests.
  - See all your friends in one list.
  - Get notified when a friend asks to connect or sends you a film.
- Screenshot: Friend search and requests. Caption: Find people, keep your circle close.

### 5. Recommend films to friends  (id: `recommend`)

- Benefit: Send a film you loved with a short note, and see what your friends send you.
- Bullets:
  - Choose a film, write a note and send it to a friend.
  - Find film recommendations in your notifications.
  - Mark notifications as read.
- Screenshot: Film recommendation sent to a friend, then the notifications inbox. Caption: Recommend a film, with a note.

### 6. Your account, everywhere  (id: `account`)

- Benefit: Create an account and your lists go with you.
- Bullets:
  - Create an account or sign in.
  - Your lists are saved on the server, not just on one phone.
- Screenshot: Sign-in screen. Caption: One account, every phone you use.

## How it works (3 steps)

1. **Create your account**
   Sign up and set up your profile with a photo and a short bio.
2. **Build your lists**
   Search for films and add them to your Top 5, your watched list or your watchlist.
3. **Share with friends**
   Connect with friends and send them the films you think they will love.

## FAQ

**Do I need an account?**
Yes. Your account keeps your lists and your friends connected to you, on any phone you sign in on.

**Where do film details come from?**
Film search and details come from a film data service. Details such as the poster, synopsis and cast come from that service.

**How do friends connect?**
Search for a friend by name and send a request. They can accept or decline it, and you can cancel a request you sent.

**Can I remove a film from a list?**
Yes. Change any list in one tap, and take a film off it whenever you like.

## Final call to action  (id: `get-app`)

- H2: Start your film list today.
- Paragraph: Download Film Wise, then build the list that is yours.
- Store buttons: Download on the App Store · Get it on Google Play
- Store links: **to be provided** (see README).

## Footer

- Brand line: Film Wise, presented by Media GCP Production.
- Links: Privacy policy · Contact
- Contact email: **to be provided**
- Copyright line: © 2026 Film Wise. All rights reserved.

## Sticky mobile bar

- Button: Get the app (same label as the header and hero)

---

## Still to provide before launch

| Item | Where it goes |
|---|---|
| iOS App Store link and Google Play link | Final CTA buttons, sticky bar |
| Production domain | `canonical`, `og:url`, `og:image`, JSON-LD, `sitemap.xml`, `robots.txt` |
| Logo files (SVG and PNG, light and dark) | `assets/logo.svg`, favicon, OG image |
| Privacy policy text | `privacy.html` |
| Contact email | Footer, `privacy.html` |
| Film data service name and attribution | FAQ answer on where details come from |
| Supported platforms and pricing, if you want them in FAQ | Not on the page yet |
