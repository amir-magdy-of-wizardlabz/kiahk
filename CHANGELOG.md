# Changelog

All cross-port changes to kiahk. Every release is coordinated across all language ports — the version numbers below match what appears on every registry simultaneously. Per-port quirks (e.g. pub.dev scoring fixes) are called out under each version.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.5] — 2026-05-25

### Added

- **New port: PHP** — `composer require wizardlabz/kiahk` (Packagist). Requires PHP 8.1+. 50 tests, 148 assertions all green against `core/test-vectors.json`. PSR-4 namespace `Wizardlabz\Kiahk\`. `composer.json` + `phpunit.xml.dist` moved to repo root so Packagist can discover them (Packagist does not support packages in subdirectories).
- **New port: Kotlin/JVM** — `implementation("com.wizardlabz:kiahk:0.1.5")` (Maven Central). Pure Kotlin 2.1, JVM 11 target, Android-compatible (API 26+). 56 tests all green. Publishes via Sonatype Central Portal using `com.vanniktech.maven.publish` plugin with in-memory GPG signing.
- **Dart pub.dev score fixes** — added `dart/example/kiahk_example.dart` (runnable example) and dartdoc on five previously-undocumented public symbols (`CopticDate.year/month/day`, `CopticMonthRecord.month`). Targets 160/160 on pub.dev.
- **Release tooling** — `scripts/bump-version.sh OLD NEW` updates every version-pinned file in one shot. `release-c.yml` now primes the Go module proxy after each release so pkg.go.dev sees new tags within minutes instead of on first user request.

### Changed

- Expanded English-language keywords across npm, PyPI, Packagist, and NuGet (added `gregorian`, `julian`, `date-conversion`, `liturgical`, `feasts`, `alexandrian`, `anno-martyrum`, `copts`, `coptic-orthodox`).
- Main README gained an FAQ section answering the most-searched Coptic-calendar questions ("when is Coptic Christmas", "when is Coptic Easter", "what are the months", etc.).

### Distributions live at this version

| Channel | URL |
|---|---|
| npm | https://www.npmjs.com/package/kiahk/v/0.1.5 |
| PyPI | https://pypi.org/project/kiahk/0.1.5/ |
| Packagist (PHP) | https://packagist.org/packages/wizardlabz/kiahk |
| pub.dev (Dart) | https://pub.dev/packages/kiahk/versions/0.1.5 |
| pkg.go.dev | https://pkg.go.dev/github.com/amir-magdy-of-wizardlabz/kiahk@v0.1.5 |
| NuGet (C#) | https://www.nuget.org/packages/Kiahk/0.1.5 |
| Maven Central (Kotlin) | https://central.sonatype.com/artifact/com.wizardlabz/kiahk/0.1.5 |
| CocoaPods (Swift) | https://cocoapods.org/pods/Kiahk |
| GitHub Release (C tarball) | https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.5 |

---

## [0.1.4] — 2026-05-25

### Changed

- **Go port: `go.mod` moved to repo root.** Module path is now `github.com/amir-magdy-of-wizardlabz/kiahk` (was `…/kiahk/go`). The Go package itself still lives in `go/` and is imported as `github.com/amir-magdy-of-wizardlabz/kiahk/go` — same import path consumers used before. The change eliminates subdirectory-prefixed git tags: from this release on, a single `v0.1.4` tag publishes every port (no more `go/v0.1.3` style tags).
- **CocoaPods publishing fixed.** `Kiahk.podspec` was failing `pod spec lint` on the `macos-14` GitHub runner because of an Xcode SWIFT_VERSION compatibility issue. `s.swift_versions` corrected to `['5.0']` (CocoaPods accepts only major Swift versions) and the workflow now passes `--swift-version=5.0` explicitly to both lint and trunk push.
- **pub.dev release workflow now skips gracefully** when the version already exists on pub.dev — so re-runs and the manual-bootstrap pattern used for first releases don't surface as workflow failures.

### Added

- Coordinated release across every port (lockstep version bumps).
- This was the first release after the publishing infrastructure was complete; all 7 release workflows fired in parallel from a single `v0.1.4` tag.

---

## [0.1.3] — 2026-05-24

### Added

- **First Packagist-discoverable PHP release** (technically: PHP port preview at dev-master via Packagist; first tagged version available from 0.1.5).
- **First pub.dev release** — `kiahk` package live on pub.dev. Initial publish was done manually to claim the name; subsequent versions use the OIDC-based automated publishing workflow.
- **First PyPI release** — `pip install kiahk` works. Published via PyPI Trusted Publisher (OIDC, no token).
- **First CocoaPods release** — `pod 'Kiahk'` works. The `Kiahk` pod name was claimed by the first trunk push.

### Initial publishing infrastructure

- `release-npm.yml` — npm with `--provenance` attestation
- `release-pypi.yml` — PyPI Trusted Publisher (OIDC, no token)
- `release-pub.yml` — pub.dev automated publishing (OIDC, no token)
- `release-nuget.yml` — NuGet with API key
- `release-cocoapods.yml` — CocoaPods trunk publish on macOS runner
- `release-c.yml` — GitHub Release with `kiahk-c-vX.Y.Z.tar.gz` source tarball

---

## [0.1.2] — 2026-05-24

### Added

- npm publishing pipeline. First successful publish of `kiahk@0.1.2` to npmjs.org.
- Demo page at `demo/index.html` — interactive Coptic date converter + feast-year viewer. Hosted via `raw.githack.com` for proper MIME types from GitHub master.
- English + Arabic Coptic month-name rendering across every port (`CopticCalendar.monthName(month, locale)`).
- Per-port `.gitignore` files for language-specific build artifacts.

### Fixed

- JS port's `feasts-data.ts` was reading `core/feasts.json` via Node's `fs` module, which broke browser builds. Data is now inlined as TypeScript constants — same pattern used in every other port.

---

## [0.1.0] — 2026-05-23

### Added

- **Initial release.** Coptic calendar arithmetic — Gregorian↔Coptic date conversion, Coptic Easter (via Meeus's Julian computus), and the major fixed and moveable Coptic Orthodox feasts.
- 7 ports established under a single canonical spec in `core/`: JavaScript/TypeScript, Python, Go, Dart, Swift, C#, and C. Every port produces identical results against `core/test-vectors.json`.
- Spec-first repository layout: `core/algorithms.md` (pseudocode), `core/feasts.json` (feast registry), `core/coptic_months.json` (month names EN+AR), `core/test-vectors.json` (cross-port test contract).
- MIT license.

[0.1.5]: https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.5
[0.1.4]: https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.4
[0.1.3]: https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.3
[0.1.2]: https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.2
[0.1.0]: https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/tag/v0.1.0
