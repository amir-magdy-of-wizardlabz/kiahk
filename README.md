<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk

Coptic calendar arithmetic — date conversion, Easter, and feast days. Ported to multiple languages from a single canonical spec in `core/`.

## Build status

[![js tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-js.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-js.yml)
[![py tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-py.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-py.yml)
[![go tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-go.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-go.yml)
[![dart tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-dart.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-dart.yml)
[![swift tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-swift.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-swift.yml)
[![csharp tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-csharp.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-csharp.yml)
[![c tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-c.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-c.yml)

(Additional language badges added as their ports land — see `docs/superpowers/specs/2026-05-23-multi-language-ports-design.md`.)

## Ports

| Language | Directory | Status |
| --- | --- | --- |
| TypeScript | `js/` | reference port |
| Python | `py/` | released |
| Go | `go/` | released |
| Dart | `dart/` | released |
| Swift | `swift/` | released |
| C# | `csharp/` | released |
| C | `c/` | released |

## Canonical spec

- `core/algorithms.md` — pseudocode for Gregorian↔Coptic, Easter, feasts
- `core/feasts.json` — fixed + moveable feast registry
- `core/test-vectors.json` — cross-port test contract

Every port must produce identical results against `core/test-vectors.json`.

## Demo

**Try it live → <https://raw.githack.com/amir-magdy-of-wizardlabz/kiahk/master/demo/index.html>**

<p align="center">
  <a href="https://raw.githack.com/amir-magdy-of-wizardlabz/kiahk/master/demo/index.html">
    <img src="assets/demo-screenshot.png" alt="Kiahk demo screenshot" width="640">
  </a>
</p>

A small browser demo of the JS port lives in [`demo/`](demo/). It lets you:

- Pick a Gregorian date and see its Coptic equivalent (English + Arabic month names)
- Enter a Gregorian year and view every major Coptic feast (en + ar names, fixed vs moveable)

Source: [`demo/index.html`](demo/index.html), [`demo/app.js`](demo/app.js). See [`demo/README.md`](demo/README.md) for how to run it locally.

> The hosted demo is served via [raw.githack.com](https://raw.githack.com), a free proxy that serves GitHub files with correct MIME types. It reads `master` directly, so the link tracks whatever's on `master` at any given moment.

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
