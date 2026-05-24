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

(Additional language badges added as their ports land — see `docs/superpowers/specs/2026-05-23-multi-language-ports-design.md`.)

## Ports

| Language | Directory | Status |
| --- | --- | --- |
| TypeScript | `js/` | reference port |
| Python | `py/` | released |
| Go | `go/` | released |
| Dart | `dart/` | this PR |
| Swift | `swift/` | planned |
| C# | `csharp/` | planned |
| C | `c/` | planned |

## Canonical spec

- `core/algorithms.md` — pseudocode for Gregorian↔Coptic, Easter, feasts
- `core/feasts.json` — fixed + moveable feast registry
- `core/test-vectors.json` — cross-port test contract

Every port must produce identical results against `core/test-vectors.json`.

## License

MIT
