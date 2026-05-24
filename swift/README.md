<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk (Swift)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Swift port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

## Install

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/amir-magdy-of-wizardlabz/kiahk.git", from: "0.1.0"),
],
targets: [
    .target(name: "YourTarget", dependencies: [
        .product(name: "Kiahk", package: "kiahk"),
    ]),
]
```

> The Swift package lives at the **`swift/` subpath** of the repo. SwiftPM consumers may need to point the package URL at the subpath or wait for a tagged release that publishes the Swift package as the root of a dedicated `swift-vX.Y.Z` tag. See the release workflow in `docs/superpowers/specs/2026-05-23-multi-language-ports-design.md` §10.

## Quick start

```swift
import Kiahk

// Convert Gregorian → Coptic
let g = try GregorianDate(year: 2025, month: 1, day: 11)
let c = try g.toCoptic()
print(c.year, c.month, c.day) // 1741 5 3

// Convert Coptic → Gregorian
let c2 = try CopticDate(year: 1742, month: 1, day: 1)
let g2 = try c2.toGregorian()
print(g2.year, g2.month, g2.day) // 2025 9 11

// Coptic Easter for a Gregorian year
let easter = try CopticCalendar.easterDate(gregorianYear: 2025)
print(easter.year, easter.month, easter.day) // 2025 4 20

// All major feasts for a Gregorian year, sorted by date
for feast in CopticCalendar.yearFeasts(gregorianYear: 2025) {
    let d = feast.gregorianDate
    let name = (try? feast.name(locale: "en")) ?? "?"
    print(String(format: "%04d-%02d-%02d  %@", d.year, d.month, d.day, name))
}
```

## API at a glance

| Type / function | Purpose |
| --- | --- |
| `try GregorianDate(year:month:day:)` | Validating init; throws `KiahkError.invalidGregorianDate` on bad input |
| `try GregorianDate.toCoptic()` → `CopticDate` | Convert (extension) |
| `GregorianDate.toDate()` / `GregorianDate(date:)` | Interop with Foundation `Date` |
| `try CopticDate(year:month:day:)` | Validating init; throws `KiahkError.invalidCopticDate` |
| `try CopticDate.toGregorian()` → `GregorianDate` | Convert |
| `Feast` | `id`, `type`, `category`, `names`, `gregorianDate`, `name(locale:)` |
| `try feast.name(locale: "fr")` | Throws `KiahkError.unsupportedLocale` for unknown locale |
| `try CopticCalendar.easterDate(gregorianYear:)` → `GregorianDate` | Coptic Easter |
| `try CopticCalendar.moveableFeast(id:gregorianYear:)` → `Feast` | One moveable feast |
| `CopticCalendar.yearFeasts(gregorianYear:)` → `[Feast]` | All feasts, sorted ascending |

Supported locales for `Feast.name(locale:)`: `en`, `ar`.

**Error pattern** — every fallible operation throws a single `KiahkError` enum with three cases (`invalidCopticDate`, `invalidGregorianDate`, `unsupportedLocale`). Pattern-match with `catch KiahkError.invalidCopticDate(...)`.

## Run tests

```bash
cd swift
swift test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
