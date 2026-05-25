# Changelog

## 0.1.5

- Coordinated release across all ports — no Dart API changes since 0.1.4.
- Two new sibling ports land in the same release: **PHP** (`wizardlabz/kiahk`
  on Packagist) and **Kotlin/JVM** (`com.wizardlabz:kiahk` on Maven Central,
  Android-compatible at API 26+).
- Dart-side: added `example/kiahk_example.dart` and missing dartdoc on
  `CopticDate.year/month/day` + `CopticMonthRecord.month`. Targets pub.dev's
  full 160/160 score.

## 0.1.4

- Coordinated release across all ports. No Dart API changes since 0.1.3 —
  only release-plumbing changes.
- The Go port's `go.mod` moved to the repo root, so the whole repo now uses
  a single tag scheme (`v0.1.4`, `v0.1.5`, …). No more `go/vX.Y.Z` subdirectory
  prefix needed.
- CocoaPods publishing fixed (Xcode SWIFT_VERSION compatibility).
- pub.dev release workflow now skips publishing gracefully if the version is
  already on pub.dev (so re-runs and the manual-bootstrap pattern don't
  surface as workflow failures).

## 0.1.3

- First Dart release on pub.dev.
- Coordinated release with `kiahk@0.1.3` on npm, `kiahk==0.1.3` on PyPI, and
  `github.com/amir-magdy-of-wizardlabz/kiahk/go@v0.1.3` on pkg.go.dev — all
  ports produce identical results against `core/test-vectors.json`.

### Features

- `GregorianDate(y, m, d)` and `CopticDate(y, m, d)` with validating
  constructors that throw `InvalidGregorianDateException` /
  `InvalidCopticDateException` on out-of-range input.
- `GregorianDate.toCoptic()` (extension) / `CopticDate.toGregorian()`
  conversions.
- `GregorianDate.toDateTime()` / `GregorianDate.fromDateTime(dt)` interop with
  Dart's `DateTime`.
- `CopticCalendar.easterDate(year)`, `CopticCalendar.moveableFeast(id, year)`,
  `CopticCalendar.yearFeasts(year)` for feast lookups (en + ar names).
- `CopticCalendar.monthName(month, locale)` plus `kCopticMonths` data for
  rendering Coptic month names in English or Arabic.
- Low-level algorithm functions exposed: `gregorianToJdn`, `jdnToGregorian`,
  `copticToJdn`, `jdnToCoptic`, `gregorianToCoptic`, `copticToGregorian`,
  `computeEaster`, `addDays`.
