# Contributing to kiahk

Thanks for the interest. kiahk is a small library with an unusual layout — this doc explains how the spec-first, multi-port pattern works so contributions land cleanly.

If you're a **user** reporting a bug or asking how to do something, just open an issue: <https://github.com/amir-magdy-of-wizardlabz/kiahk/issues>. The rest of this document is for **contributors** who want to add code, fix a bug, or contribute a new language port.

---

## 1. Repository layout in one diagram

```
aboqty/                              (working dir; library is named "kiahk")
│
├── core/                            ← canonical spec — source of truth
│   ├── algorithms.md                  pseudocode for every conversion + Easter
│   ├── coptic_months.json             13 Coptic month names (en + ar)
│   ├── feasts.json                    fixed + moveable feast registry
│   └── test-vectors.json              cross-port test contract
│
├── js/         py/      go/         ← 9 language ports as sibling dirs
├── dart/       swift/   csharp/        each with its own README + tests
├── c/          php/     kotlin/        identical results vs core/test-vectors.json
│
├── Package.swift                    ← root-level manifests for ecosystems that
├── Kiahk.podspec                       require it (SwiftPM, CocoaPods,
├── go.mod                              Go modules, Composer/Packagist)
├── composer.json
│
├── .github/workflows/
│   ├── test-*.yml                   ← per-port CI: runs on every PR touching that port
│   └── release-*.yml                ← per-channel publishing: fires on v*.*.* tag push
│
├── scripts/
│   └── bump-version.sh              ← bumps every version-pinned file in lockstep
│
└── demo/                            ← browser demo (JS port)
```

## 2. The spec-first contract

The library exists in 9 languages but is **one mathematical implementation**. The single source of truth is [`core/`](core/):

- `core/algorithms.md` — language-agnostic pseudocode. Every port implements these exactly.
- `core/test-vectors.json` — the contract every port is tested against. If you change one, you must change the other across every port simultaneously.

**Rule of thumb:** if you find a bug in port X, suspect the code in port X first — `core/algorithms.md` is authoritative. If the spec disagrees with reality, both need updating.

## 3. Local development per port

Each port has its own README with detailed instructions. The short version:

| Port | Setup | Run tests |
|---|---|---|
| `js/` | `cd js && npm install && npm run build` | `npm test` |
| `py/` | `cd py && python3 -m venv .venv && .venv/bin/pip install -e ".[dev]"` | `.venv/bin/pytest` |
| `go/` | (none — Go fetches deps) | `go test ./go/...` (from repo root) |
| `dart/` | `cd dart && dart pub get` | `dart test` |
| `swift/` | (none if you have Xcode/Swift) | `cd swift && swift test` |
| `csharp/` | (none if you have .NET 8 SDK) | `cd csharp && dotnet test` |
| `c/` | (none — uses CMake) | `cd c && cmake -S . -B build && cmake --build build && ctest --test-dir build` |
| `php/` | (none — composer fetches deps from root) | `composer install && composer test` (from repo root) |
| `kotlin/` | (none — Gradle fetches deps) | `cd kotlin && gradle test` |

If a test fails on a particular port but the same input passes elsewhere, that's a real divergence — please file an issue with the input and both observed outputs.

## 4. Adding a new language port

This is the most welcome kind of contribution. There are about a dozen mainstream languages without a Coptic-calendar library and the algorithms are small (~200 lines of code per port, including tests).

To add port `<lang>/`:

1. **Read `core/algorithms.md` end-to-end.** All the math is there.
2. **Copy an existing port as a template.** The Go and Python ports are the simplest reads; the Swift and Kotlin ports show idiomatic strongly-typed value types.
3. **Mirror the public API:**
   - Types: `GregorianDate`, `CopticDate`, `Feast` (all with validating constructors)
   - Errors: `InvalidGregorianDateException` / `InvalidCopticDateException` / `InvalidCopticMonthException` / `UnsupportedLocaleException` / `UnknownFeastException` (use idiomatic names for your language — `Error`, `Exception`, `Result`, etc.)
   - Facade: `CopticCalendar.easterDate(year)`, `moveableFeast(id, year)`, `fixedFeasts(year)`, `yearFeasts(year)`, `monthName(month, locale)`
   - Pure-math layer: `gregorianToJdn`, `jdnToGregorian`, `copticToJdn`, `jdnToCoptic`, `computeEaster`, `addDays`
4. **Inline the data tables** (`core/feasts.json` and `core/coptic_months.json`) into your port's source — don't read the JSON files at runtime. Every other port does this so the published library is fully self-contained.
5. **Write tests that load `core/test-vectors.json`** and run every case in `gregorian_to_coptic`, `coptic_to_gregorian`, `easter`, `moveable_feasts`, `invalid_gregorian_dates`, `invalid_coptic_dates`, and `coptic_month_names`. The Python port (`py/tests/`) is the smallest reference implementation.
6. **Add a `.github/workflows/test-<lang>.yml`** CI workflow (copy any existing `test-*.yml` and adjust the language-specific commands).
7. **Add an entry to:**
   - The "Ports & distributions" table in the root `README.md`
   - The package-versions and build-status badge rows in the root `README.md`
   - `CHANGELOG.md` under the next unreleased version
   - `memory/project_structure.md` if the port introduces a new ecosystem constraint (e.g. another root-level manifest)
8. **Optional (if your ecosystem has a public registry):** add a `.github/workflows/release-<channel>.yml` workflow that publishes on `v*.*.*` tag pushes. Document required GitHub Secrets in a comment at the top of the workflow file.

## 5. Pull request workflow

1. Fork the repo and create a feature branch (any name).
2. Make your changes. Run the relevant port's tests locally.
3. Open a PR against `master` using the PR template.
4. CI will run the touched port's test workflow (path-filtered). All checks must be green.
5. I'll review within a few days. For new-port PRs, expect 1-2 rounds of review on naming + idiom alignment.

### Commit messages

Free-form. Keep the subject line under ~70 chars. No special trailers required.

### Lockstep versioning

Don't bump versions in a feature PR. Releases are coordinated across all ports via `scripts/bump-version.sh` and tagged in a separate release commit.

## 6. Issues / discussions

- **Bug reports:** include the port, version, input, expected output, observed output.
- **Feature requests:** explain the use case first — "I'd like to render Coptic dates in my Flutter app" is enough; I'll propose an API in the discussion.
- **Questions:** open an issue with the `question` label.
- **Security issues:** see [`SECURITY.md`](SECURITY.md) (private disclosure channel).

## 7. License

By contributing, you agree your contribution is licensed under the same [MIT License](LICENSE) as the rest of the project.

---

Maintained by [Amir Magdy](https://github.com/amir-magdy-of-wizardlabz) at WizardLabz.
