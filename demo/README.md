# Kiahk Demo

A tiny browser demo of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk), the Coptic calendar library.

Two features:

1. **Date converter** — pick a Gregorian date, see the Coptic equivalent.
2. **Feasts of the year** — enter a Gregorian year, see every major Coptic feast that falls inside it (en + ar names, fixed vs moveable).

## Run locally

The demo imports the compiled JS port directly via ES modules. Build `js/` first, then serve the demo over HTTP (modules don't work via `file://`):

```bash
# 1. Build the JS port
cd js
npm install
npm run build
cd ..

# 2. Serve from the repo root so the relative import `../js/dist/index.js` resolves
python3 -m http.server 8080 --directory .

# 3. Open in your browser
open http://localhost:8080/demo/
```

Or with Node's built-in server:

```bash
npx --yes http-server -p 8080
# then http://localhost:8080/demo/
```

## What's inside

- `index.html` — page layout
- `app.js` — vanilla JS, imports `GregorianDate` + `CopticCalendar` from `../js/dist/index.js`
- `style.css` — minimal styling, matches the kiahk brand colors

No build step, no framework, no dependencies on this side — the demo is plain ESM.

## Hosting

To host as a static site (e.g. GitHub Pages, Netlify, Vercel), bundle the kiahk source into a single file using esbuild/Vite first, or commit the `js/dist/` directory so the relative import keeps working.
