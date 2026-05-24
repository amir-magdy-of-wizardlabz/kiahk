<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk (C#)

[![NuGet version](https://img.shields.io/nuget/v/Kiahk.svg)](https://www.nuget.org/packages/Kiahk/)
[![NuGet downloads](https://img.shields.io/nuget/dt/Kiahk.svg)](https://www.nuget.org/packages/Kiahk/)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. C# port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Package:** <https://www.nuget.org/packages/Kiahk/>

## Install

```bash
dotnet add package Kiahk
```

Or from this repo for development:

```bash
cd csharp
dotnet build
```

## Quick start

```csharp
using Kiahk;

// Convert Gregorian → Coptic
var g = new GregorianDate(2025, 1, 11);
var c = g.ToCoptic();
Console.WriteLine($"{c.Year} {c.Month} {c.Day}"); // 1741 5 3

// Convert Coptic → Gregorian
var c2 = new CopticDate(1742, 1, 1);
var g2 = c2.ToGregorian();
Console.WriteLine($"{g2.Year} {g2.Month} {g2.Day}"); // 2025 9 11

// Coptic Easter for a Gregorian year
var easter = CopticCalendar.EasterDate(2025);
Console.WriteLine($"{easter.Year} {easter.Month} {easter.Day}"); // 2025 4 20

// All major feasts for a Gregorian year, sorted by date
foreach (var feast in CopticCalendar.YearFeasts(2025))
{
    var d = feast.GregorianDate;
    Console.WriteLine($"{d.Year}-{d.Month:D2}-{d.Day:D2}  {feast.Name("en")}");
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

The library exposes Coptic month names in `en` + `ar` via `CopticCalendar.MonthName(month, locale)`. The full 13-entry table is also re-exported as `CopticMonthsData.Months` for callers that prefer raw data.

```csharp
using Kiahk;

var g = new GregorianDate(2025, 4, 20);
var c = g.ToCoptic();
Console.WriteLine($"{c.Day} {CopticCalendar.MonthName(c.Month, "en")} {c.Year} AM");
Console.WriteLine($"{c.Day} {CopticCalendar.MonthName(c.Month, "ar")} {c.Year} للشهداء");
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `new GregorianDate(int y, int m, int d)` | Validating ctor; throws `InvalidGregorianDateException` on bad input |
| `GregorianDate.ToCoptic() → CopticDate` | Convert (partial-class extension) |
| `GregorianDate.ToDateOnly()` / `GregorianDate.FromDateOnly(DateOnly d)` | Interop with `System.DateOnly` (.NET 6+) |
| `new CopticDate(int y, int m, int d)` | Validating ctor; throws `InvalidCopticDateException` on bad input |
| `CopticDate.ToGregorian() → GregorianDate` | Convert |
| `Feast` | `Id`, `Type`, `Category`, `Names`, `GregorianDate`, `Name(locale)` |
| `Feast.Name("fr")` | Throws `UnsupportedLocaleException` for unknown locale |
| `CopticCalendar.EasterDate(int year) → GregorianDate` | Coptic Easter |
| `CopticCalendar.MoveableFeast(string id, int year) → Feast` | One moveable feast |
| `CopticCalendar.YearFeasts(int year) → IReadOnlyList<Feast>` | All feasts, sorted ascending |
| `CopticCalendar.MonthName(int month, string locale) → string` | Coptic month name; throws `InvalidCopticMonthException` / `UnsupportedLocaleException` |
| `CopticMonthsData.Months` | 13-entry `IReadOnlyList<CopticMonthRecord>` (mirrors `core/coptic_months.json`) |

Supported locales for `Feast.Name(...)` and `CopticCalendar.MonthName(...)`: `en`, `ar`.

**Algorithm primitives** are exposed via `Kiahk.Algorithms` (static class): `GregorianToJdn`, `JdnToGregorian`, `CopticToJdn`, `JdnToCoptic`, `GregorianToCoptic`, `CopticToGregorian`, `ComputeEaster`, `AddDays` — all return `(int Year, int Month, int Day)` named tuples.

## Run tests

```bash
cd csharp
dotnet test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
