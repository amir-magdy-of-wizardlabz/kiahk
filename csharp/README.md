<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# Kiahk (C#)

Coptic calendar arithmetic — date conversion, Easter, and feast days. C# port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

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

Supported locales for `Feast.Name(...)`: `en`, `ar`.

**Algorithm primitives** are exposed via `Kiahk.Algorithms` (static class): `GregorianToJdn`, `JdnToGregorian`, `CopticToJdn`, `JdnToCoptic`, `GregorianToCoptic`, `CopticToGregorian`, `ComputeEaster`, `AddDays` — all return `(int Year, int Month, int Day)` named tuples.

## Run tests

```bash
cd csharp
dotnet test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
