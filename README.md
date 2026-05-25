<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk

[![GitHub stars](https://img.shields.io/github/stars/amir-magdy-of-wizardlabz/kiahk?style=flat&logo=github)](https://github.com/amir-magdy-of-wizardlabz/kiahk/stargazers)
[![GitHub contributors](https://img.shields.io/github/contributors/amir-magdy-of-wizardlabz/kiahk.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/amir-magdy-of-wizardlabz/kiahk.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/issues)
[![GitHub last commit](https://img.shields.io/github/last-commit/amir-magdy-of-wizardlabz/kiahk.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/commits/master)
[![License: MIT](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. A small, exact library for the **Coptic Orthodox (Alexandrian) calendar**: convert between Gregorian and Coptic dates, compute Coptic Easter (Pascha) using the Julian computus, and look up the major fixed and moveable feasts of the Coptic Orthodox church year. Ported to **9 languages** from a single canonical spec in [`core/`](core/) — every port produces identical results against the shared test vectors.

**At a glance:** Anno Martyrum (AM) era · 13-month year (12×30 days + Nasie) · Julian-style leap rule (Y mod 4 == 3) · Coptic Easter via Meeus's compact Julian computus · English and Arabic month + feast names built in.

## Package versions

[![npm](https://img.shields.io/npm/v/kiahk.svg?label=npm&logo=npm)](https://www.npmjs.com/package/kiahk)
[![PyPI](https://img.shields.io/pypi/v/kiahk.svg?label=PyPI&logo=pypi&logoColor=white)](https://pypi.org/project/kiahk/)
[![Packagist](https://img.shields.io/packagist/v/wizardlabz/kiahk.svg?label=Packagist&logo=packagist)](https://packagist.org/packages/wizardlabz/kiahk)
[![Maven Central](https://img.shields.io/maven-central/v/com.wizardlabz/kiahk.svg?label=Maven%20Central&logo=apachemaven)](https://central.sonatype.com/artifact/com.wizardlabz/kiahk)
[![pub.dev](https://img.shields.io/pub/v/kiahk.svg?label=pub.dev&logo=dart)](https://pub.dev/packages/kiahk)
[![pkg.go.dev](https://img.shields.io/github/v/tag/amir-magdy-of-wizardlabz/kiahk?filter=v*&label=pkg.go.dev&logo=go)](https://pkg.go.dev/github.com/amir-magdy-of-wizardlabz/kiahk/go)
[![NuGet](https://img.shields.io/nuget/v/Kiahk.svg?label=NuGet&logo=nuget)](https://www.nuget.org/packages/Kiahk/)
[![CocoaPods](https://img.shields.io/cocoapods/v/Kiahk.svg?label=CocoaPods&logo=cocoapods)](https://cocoapods.org/pods/Kiahk)
[![SwiftPM](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Famir-magdy-of-wizardlabz%2Fkiahk%2Fbadge%3Ftype%3Dswift-versions&label=SwiftPM&logo=swift)](https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk)
[![C release](https://img.shields.io/github/v/release/amir-magdy-of-wizardlabz/kiahk?label=C%20tarball&logo=github)](https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/latest)

## Build status

[![js tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-js.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-js.yml)
[![py tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-py.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-py.yml)
[![go tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-go.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-go.yml)
[![dart tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-dart.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-dart.yml)
[![swift tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-swift.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-swift.yml)
[![csharp tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-csharp.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-csharp.yml)
[![c tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-c.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-c.yml)
[![php tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-php.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-php.yml)
[![kotlin tests](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-kotlin.yml/badge.svg)](https://github.com/amir-magdy-of-wizardlabz/kiahk/actions/workflows/test-kotlin.yml)

## Ports & distributions

Same algorithms, same `core/test-vectors.json` contract, distributed through each language's native package manager. Every port version is kept in lockstep — the version badges below should all read the same number.

| Language | Source | Package | Install |
| --- | --- | --- | --- |
| TypeScript / JavaScript | [`js/`](js/) | [![npm](https://img.shields.io/npm/v/kiahk.svg?label=npm)](https://www.npmjs.com/package/kiahk) | `npm install kiahk` |
| Python | [`py/`](py/) | [![PyPI](https://img.shields.io/pypi/v/kiahk.svg?label=PyPI)](https://pypi.org/project/kiahk/) | `pip install kiahk` |
| PHP | [`php/`](php/) | [![Packagist](https://img.shields.io/packagist/v/wizardlabz/kiahk.svg?label=Packagist)](https://packagist.org/packages/wizardlabz/kiahk) | `composer require wizardlabz/kiahk` |
| Go | [`go/`](go/) | [![pkg.go.dev](https://pkg.go.dev/badge/github.com/amir-magdy-of-wizardlabz/kiahk/go.svg)](https://pkg.go.dev/github.com/amir-magdy-of-wizardlabz/kiahk/go) | `go get github.com/amir-magdy-of-wizardlabz/kiahk/go` |
| Dart / Flutter | [`dart/`](dart/) | [![pub.dev](https://img.shields.io/pub/v/kiahk.svg?label=pub.dev)](https://pub.dev/packages/kiahk) | `dart pub add kiahk` |
| Swift (SwiftPM) | [`swift/`](swift/) | [![SwiftPM](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Famir-magdy-of-wizardlabz%2Fkiahk%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/amir-magdy-of-wizardlabz/kiahk) | add `https://github.com/amir-magdy-of-wizardlabz/kiahk.git` to `Package.swift` |
| Swift (CocoaPods) | [`swift/`](swift/) | [![CocoaPods](https://img.shields.io/cocoapods/v/Kiahk.svg?label=CocoaPods)](https://cocoapods.org/pods/Kiahk) | `pod 'Kiahk'` in `Podfile` |
| C# / .NET | [`csharp/`](csharp/) | [![NuGet](https://img.shields.io/nuget/v/Kiahk.svg?label=NuGet)](https://www.nuget.org/packages/Kiahk/) | `dotnet add package Kiahk` |
| Kotlin / JVM / Android | [`kotlin/`](kotlin/) | [![Maven Central](https://img.shields.io/maven-central/v/com.wizardlabz/kiahk.svg?label=Maven%20Central)](https://central.sonatype.com/artifact/com.wizardlabz/kiahk) | `implementation("com.wizardlabz:kiahk:0.1.5")` in Gradle |
| C | [`c/`](c/) | [![Release](https://img.shields.io/github/v/release/amir-magdy-of-wizardlabz/kiahk?label=release)](https://github.com/amir-magdy-of-wizardlabz/kiahk/releases/latest) | download tarball or `add_subdirectory(c)` in CMake |

See each port's README for full install + quick-start examples, and for English + Arabic month-name rendering.

## Canonical spec

- `core/algorithms.md` — pseudocode for Gregorian↔Coptic, Easter, feasts
- `core/feasts.json` — fixed + moveable feast registry
- `core/coptic_months.json` — the 13 Coptic month names (English + Arabic)
- `core/test-vectors.json` — cross-port test contract

Every port must produce identical results against `core/test-vectors.json`.

## FAQ

### What is the Coptic calendar?
The Coptic (Alexandrian) calendar is the liturgical calendar of the Coptic Orthodox Church of Alexandria. It derives from the ancient Egyptian civil calendar and was reformed by Augustus in 25 BC. Its era is **Anno Martyrum (AM)** — "Year of the Martyrs" — counted from **29 August 284 CE (Julian)**, the year of Diocletian's accession and the persecution of Christians.

### What are the months of the Coptic year?
There are **13 months**: 12 of exactly 30 days each, plus a short 13th month called **Nasie** of 5 days (6 in leap years). In order: Thout · Paopi · Hathor · Koiak · Tobi · Meshir · Paremhat · Parmouti · Pashons · Paoni · Epip · Mesori · Nasie. (Arabic: توت · بابة · هاتور · كيهك · طوبة · أمشير · برمهات · برمودة · بشنس · بؤونة · أبيب · مسرى · نسيء.) Available via `CopticCalendar.monthName(month, locale)` in every port.

### When does the Coptic year start?
**1 Tout** — falling on either **11 September** or **12 September** in the Gregorian calendar (the later date in the Gregorian year preceding a leap year). The current Coptic year began on 11 September 2025 (Gregorian) and is **1742 AM**.

### When is Coptic Christmas?
**29 Koiak** in the Coptic calendar, which falls on **7 January** in the Gregorian calendar every year (in the 20th–21st centuries). Same day every year because the Coptic calendar is fixed relative to the Julian calendar, and the Julian-to-Gregorian offset stays at +13 days through 28 February 2100.

### When is Coptic Easter?
Coptic Easter follows the **Julian computus** — the same calculation used by all Eastern Orthodox churches. It can fall anywhere between **April 4 and May 8** in the Gregorian calendar. Examples: 2025 → April 20, 2026 → April 12, 2027 → May 2, 2028 → April 16. Use `CopticCalendar.easterDate(gregorianYear)` to compute it.

### How is Coptic Easter different from Western (Gregorian) Easter?
Both use the same underlying rule ("Sunday after the first full moon on or after the spring equinox") but with different reference frames. Western Easter uses the Gregorian calendar and Gregorian computus; Coptic and Eastern Orthodox Easter use the Julian calendar and Julian computus. The two coincide in some years and can be up to **5 weeks apart** in others. Kiahk implements only the Coptic/Julian variant.

### What are the major Coptic feasts?
The seven major fixed feasts and the moveable feasts derived from Easter:

| Feast | Type | Date |
|---|---|---|
| Nativity of Christ | fixed | 29 Koiak (7 January) |
| Epiphany (Theophany) | fixed | 11 Tobi (19 January) |
| Annunciation | fixed | 29 Paremhat (7 April) |
| Palm Sunday | moveable | Easter − 7 days |
| Easter Sunday | moveable | — |
| Ascension | moveable | Easter + 39 days |
| Pentecost | moveable | Easter + 49 days |
| Feast of the Cross | fixed | 17 Thout (27 September) |
| Assumption of Mary | fixed | 16 Mesori (22 August) |

Plus the start of major fasts: Nineveh Fast (Easter − 69 days) and Great Lent (Easter − 55 days).

### How does the Coptic leap year rule work?
A Coptic year `Y` is a leap year if and only if `Y mod 4 == 3`. This is the Julian-style leap rule (one leap every 4 years, no century exception). The extra day always goes to month 13 (Nasie), giving it 6 days instead of 5.

### Why does Kiahk use Julian Day Numbers internally?
The **Julian Day Number (JDN)** is a continuous integer count of days from a single epoch (noon UTC, 1 January 4713 BC proleptic Julian). Routing every conversion through JDN gives you (a) one well-understood arithmetic primitive instead of N²×N two-calendar formulas, and (b) trivial day-arithmetic for moveable feasts (just add/subtract days). All 9 ports do this — see [`core/algorithms.md`](core/algorithms.md).

### Can I use Kiahk in browser JavaScript / on Android / on iOS?
Yes — every port is pure-language with no native dependencies:
- **Browser JS** — the JS port is ESM-only and has zero Node-specific APIs at runtime; works in any modern browser
- **Android** — the Kotlin/JVM port targets JVM 11, Android API 26+ (use Android Gradle Plugin's desugaring for older)
- **iOS / macOS / tvOS / watchOS / visionOS / Linux** — the Swift port is pure-Swift with only `Foundation`; works on every Apple OS plus Linux (and even Android via SwiftPM)
- **Server / CLI** — all 9 ports work as backend libraries

### How do I report a bug or suggest a feature?
Open an issue at <https://github.com/amir-magdy-of-wizardlabz/kiahk/issues>. If you have a security concern, see [`SECURITY.md`](SECURITY.md).

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
