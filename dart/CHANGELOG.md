# Changelog

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
