<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk (Swift)

[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Famir-magdy-of-wizardlabz%2Fkiahk%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Famir-magdy-of-wizardlabz%2Fkiahk%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk)
[![CocoaPods version](https://img.shields.io/cocoapods/v/Kiahk.svg)](https://cocoapods.org/pods/Kiahk)
[![GitHub stars](https://img.shields.io/github/stars/amir-magdy-of-wizardlabz/kiahk?style=flat&logo=github)](https://github.com/amir-magdy-of-wizardlabz/kiahk/stargazers)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

> Neither SwiftPM nor CocoaPods exposes reliable per-package download counts (SwiftPM has no central registry; the CocoaPods metrics service was deprecated). Adoption is tracked via GitHub stars + [Swift Package Index](https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk).

Coptic calendar arithmetic — date conversion, Easter, and feast days. Swift port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Swift Package Index:** <https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk>
**CocoaPods:** <https://cocoapods.org/pods/Kiahk>

## Install (Swift Package Manager)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/amir-magdy-of-wizardlabz/kiahk.git", from: "0.1.5"),
],
targets: [
    .target(name: "YourTarget", dependencies: [
        .product(name: "Kiahk", package: "kiahk"),
    ]),
]
```

Or in Xcode: **File → Add Package Dependencies…** and paste the repo URL.

## Install (CocoaPods)

Add to your `Podfile`:

```ruby
pod 'Kiahk', '~> 0.1.5'
```

Then `pod install`. Supports iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+.

> The repository's `Package.swift` and `Kiahk.podspec` live at the **repo root** so SwiftPM and CocoaPods both resolve the GitHub URL directly. The Swift sources themselves remain under `swift/Sources/Kiahk/` to preserve the multi-language repo layout.

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

**Sample output:**

```
1741 5 3
2025 9 11
2025 4 20
2025-01-07  Nativity of Christ
2025-01-19  Epiphany (Theophany)
2025-02-10  Nineveh Fast
2025-02-24  Great Lent (start)
2025-04-07  Annunciation
2025-04-13  Palm Sunday
2025-04-20  Easter Sunday
2025-05-29  Ascension
2025-06-08  Pentecost
2025-08-22  Assumption of Mary
2025-09-27  Feast of the Cross
```

## Render a date in English and Arabic

The library exposes Coptic month names in `en` + `ar` via `CopticCalendar.monthName(month:locale:)`. The full 13-entry table is also re-exported as `kCopticMonths` for callers that prefer raw data.

```swift
import Kiahk

let g = try GregorianDate(year: 2025, month: 4, day: 20)
let c = try g.toCoptic()
let en = try CopticCalendar.monthName(month: c.month, locale: "en")
let ar = try CopticCalendar.monthName(month: c.month, locale: "ar")
print("\(c.day) \(en) \(c.year) AM")
print("\(c.day) \(ar) \(c.year) للشهداء")
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
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
| `try CopticCalendar.monthName(month:locale:)` → `String` | Coptic month name; throws `KiahkError.invalidCopticMonth` / `.unsupportedLocale` |
| `kCopticMonths` | 13-entry `[CopticMonthRecord]` (mirrors `core/coptic_months.json`) |

Supported locales for `Feast.name(locale:)` and `CopticCalendar.monthName(month:locale:)`: `en`, `ar`.

**Error pattern** — every fallible operation throws a single `KiahkError` enum with four cases (`invalidCopticDate`, `invalidGregorianDate`, `unsupportedLocale`, `invalidCopticMonth`). Pattern-match with `catch KiahkError.invalidCopticDate(...)`.

## Run tests

```bash
# Run from the repo root (Package.swift lives there now)
swift test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
