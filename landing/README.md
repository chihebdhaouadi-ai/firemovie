# Film Wise landing page

A static, dependency-free site: HTML, CSS and a small vanilla JS file. No build step.

## Files

| Path | Purpose |
|---|---|
| `index.html` | The landing page |
| `styles.css` | All styles (tokens on `:root`) |
| `main.js` | Intro, header state, mobile menu, scroll reveals, sticky mobile CTA |
| `privacy.html` | Privacy policy stub (noindex) |
| `robots.txt`, `sitemap.xml` | Crawl files (placeholder domain) |
| `assets/` | Logo, favicon, OG image, self-hosted Poppins fonts |
| `CONTENT.md` | Every word on the page; `index.html` must match it |
| `FEATURES.md` | Feature inventory and what is verified as working |

## Run locally

```sh
cd firemovie/landing
python3 -m http.server 8010
```

Open http://127.0.0.1:8010/.

## Deploy

Upload the contents of this folder to any static host (Netlify, Cloudflare Pages, GitHub Pages, S3 + CloudFront). No server logic is needed.

Before launch, replace the placeholder domain `https://www.filmwise.example/` in:

- `index.html` (canonical, `og:url`, `og:image`, JSON-LD)
- `sitemap.xml`
- `robots.txt`

## Placeholders to replace

| Placeholder | Where |
|---|---|
| `#store-app-store-link-needed` | App Store button in the final CTA (`index.html`) |
| `#store-google-play-link-needed` | Google Play button in the final CTA (`index.html`) |
| `contact@filmwise.example` | Footer contact link (`index.html`) |
| `[Privacy policy text to be provided before launch.]` | `privacy.html` |
| Device frames marked "Screenshot pending" | Every `.device` block in `index.html` |

## Swap in real screenshots

A frame without a screenshot uses a placeholder block:

```html
<div class="device__screen device__screen--mock" aria-hidden="true">
  <div class="mock"><span></span><span></span><span></span><span></span><span></span></div>
  <span class="device__pending">Screenshot pending</span>
</div>
```

Replace the whole `device__screen` div with an image sized to the 9:19.5 frame. The existing screenshots follow this pattern:

```html
<div class="device__screen"><img src="assets/screens/find.webp" alt="" width="540" height="1174" loading="lazy"></div>
```

Put the image in `assets/screens/`, export at 2x (for example 540 x 1174), and encode as WebP or AVIF. Keep `width` and `height` set. Set `alt` to a description if the screenshot carries information the caption does not, otherwise keep `alt=""` because the caption already describes it.

## Swap in store links

Edit the two `href` values in the final CTA. Remove the `-needed` suffix only after the real URL is in place, so any stray placeholder stays easy to find with a search.

## Intro

The intro plays once per browser session (stored in `sessionStorage` under `fw-intro-seen`), lasts 2.2 seconds, and can be skipped with the button or the Escape key. It is off when the visitor's system requests reduced motion.

## Checks

- Lighthouse mobile, local build (headless Chrome, default mobile throttling): Performance 91-92, Accessibility 96, Best Practices 100, SEO 100.
  - The accessibility score loses points to a colour-contrast audit that runs during the first-visit hero fade-in. The settled text colours pass.
- No horizontal scroll at 360, 390, 768, 1024 and 1440 px. No broken images and no console errors at those widths.
- Mobile menu: opens from the Menu button, closes on a link tap and on Escape, and returns focus to the button on Escape.
- Keyboard: the skip link is the first tab stop.
- Intro: skipped by the button, shown once per session, and not shown with reduced motion. The hero appears when the intro ends.
- Sticky CTA: hidden at the top, shown between hero and final CTA, hidden once the final CTA is in view.
