# Kiahk — Design Spec
**Date:** 2026-03-21
**Status:** Approved

---

## Overview

**Kiahk** is an open-source, multi-language library for Coptic calendar arithmetic. Zero dependencies, pure algorithms, fully tested. Named after the Coptic month of Christmas (ⲕⲓⲁϩⲕ).

**Repo:** `git@github.com:amir-magdy-of-wizardlabz/kiahk.git`

---

## Repository Structure

```
kiahk/
├── core/
│   ├── algorithms.md          # Canonical algorithm documentation
│   ├── test-vectors.json      # Single source of truth for all cross-language tests
│   └── feasts.json            # Master feast registry (names, type, category, offsets)
├── js/                        # npm: kiahk
├── python/                    # PyPI: kiahk
├── dart/                      # pub.dev: kiahk
├── swift/                     # Swift Package: Kiahk
├── kotlin/                    # Maven: io.kiahk:calendar
├── csharp/                    # NuGet: Kiahk
├── assets/
│   └── icon.svg               # A4-R1 icon (amber, ⲔⲒⲀϨⲔ script, Coptic cross)
└── README.md
```

Each language directory layout:
```
<lang>/
  src/           # library source
  tests/         # test suite (reads ../../core/test-vectors.json)
  <package-config>
  README.md
```

---

## Core Layer

### `core/test-vectors.json`

Single source of truth read by all 6 language test suites.

```json
{
  "gregorian_to_coptic": [
    { "gregorian": { "year": 2025, "month": 1, "day": 11 },
      "coptic":    { "year": 1741, "month": 5,  "day": 2  } }
  ],
  "coptic_to_gregorian": [
    { "coptic":    { "year": 1741, "month": 5, "day": 2 },
      "gregorian": { "year": 2025, "month": 1, "day": 11 } }
  ],
  "easter": [
    { "gregorian_year": 2025, "date": { "year": 2025, "month": 4, "day": 20 } },
    { "gregorian_year": 2026, "date": { "year": 2026, "month": 4, "day": 5  } }
  ],
  "moveable_feasts": [
    { "gregorian_year": 2025, "feast_id": "nineveh_fast",
      "date": { "year": 2025, "month": 2, "day": 3 } }
  ],
  "year_feasts": [
    { "gregorian_year": 2025, "count": 42 }
  ]
}
```

Easter test vectors cover 2025–2037, verified against printed Coptic pocket calendars with Nineveh Fast as ground truth.

### `core/feasts.json`

Master feast registry. Every language reads this at runtime or build time.

```json
[
  {
    "id": "nativity",
    "names": { "en": "Nativity of Christ", "ar": "عيد الميلاد المجيد" },
    "type": "fixed",
    "category": "major",
    "coptic_month": 4,
    "coptic_day": 29
  },
  {
    "id": "easter",
    "names": { "en": "Easter Sunday", "ar": "عيد القيامة المجيد" },
    "type": "moveable",
    "category": "major",
    "easter_offset": 0
  },
  {
    "id": "nineveh_fast",
    "names": { "en": "Nineveh Fast", "ar": "صوم نينوى" },
    "type": "moveable",
    "category": "major",
    "easter_offset": -69
  }
]
```

### `core/algorithms.md`

Prose documentation of:
- **Julian Day Number method** for Gregorian → Coptic conversion (epoch JDN 1825030)
- **Reverse JDN method** for Coptic → Gregorian conversion
- **Butcher's algorithm** for Julian Easter + 13-day Gregorian offset
- **Moveable feast derivation** from Easter offset (positive = after, negative = before)

---

## Class API

Consistent across all 6 languages, adapted to each language's idioms.

### `CopticDate`

```
CopticDate(year: Int, month: Int, day: Int)
  → throws InvalidCopticDateException if month ∉ [1–13] or day out of range

.toGregorian() → GregorianDate
.toString()    → "1741/05/02"
```

### `GregorianDate`

```
GregorianDate(year: Int, month: Int, day: Int)
  → throws InvalidGregorianDateException if month ∉ [1–12] or day out of range

.toCoptic()               → CopticDate
.toNativeDate()           → platform native date (see table below)
.toString()               → "2025-01-11"

static .fromNativeDate(native) → GregorianDate
```

| Language   | Native type        |
|------------|--------------------|
| TypeScript | `Date`             |
| Python     | `datetime.date`    |
| Dart       | `DateTime`         |
| Swift      | `Foundation.Date`  |
| Kotlin     | `java.time.LocalDate` |
| C#         | `DateOnly`         |

### `CopticCalendar`

```
CopticCalendar (static/singleton — no instantiation)

.easterDate(gregorianYear: Int)                    → GregorianDate
.moveableFeast(feastId: String, gregorianYear: Int) → Feast
.fixedFeasts(gregorianYear: Int)                   → List<Feast>
.yearFeasts(gregorianYear: Int)                    → List<Feast>  // strict superset of fixedFeasts + all moveable feasts, sorted by Gregorian date
```

### `Feast`

```
Feast
  .name(locale: String)  → String   // "en" | "ar"; throws UnsupportedLocaleException
  .gregorianDate         → GregorianDate
  .copticDate            → CopticDate
  .type                  → FeastType      // moveable | fixed
  .category              → FeastCategory  // major | minor
  .easterOffset          → Int?           // null for fixed feasts
  .id                    → String         // e.g. "easter", "nativity"
```

### Exceptions

| Exception                    | Thrown when                                   |
|------------------------------|-----------------------------------------------|
| `InvalidCopticDateException` | Invalid month (1–13) or day for month         |
| `InvalidGregorianDateException` | Invalid month (1–12) or day for month      |
| `UnsupportedLocaleException` | `name(locale)` called with unknown locale     |

---

## Per-Language Package Configuration

| Language   | Package name        | Test framework     | Config file          |
|------------|---------------------|--------------------|----------------------|
| TypeScript | `kiahk` (npm)       | Vitest             | `package.json`       |
| Python     | `kiahk` (PyPI)      | pytest             | `pyproject.toml`     |
| Dart       | `kiahk` (pub.dev)   | dart test          | `pubspec.yaml`       |
| Swift      | `Kiahk` (SwiftPM)   | XCTest             | `Package.swift`      |
| Kotlin     | `io.kiahk:calendar` | JUnit 5 + kotlin.test | `build.gradle.kts` |
| C#         | `Kiahk` (NuGet)     | xUnit              | `Kiahk.csproj`       |

---

## Branding & Assets

- **Icon:** A4-R1 — amber calendar with ⲔⲒⲀϨⲔ Coptic script header and Coptic cross
- **Color palette:** Amber `#b45309` / `#d97706`, Parchment `#fff7ed`, Brown `#92400e`
- Saved as `assets/icon.svg` — used in README, package registry pages

---

## Algorithms (Summary)

### Gregorian ↔ Coptic (Julian Day Number)

1. Convert Gregorian date → JDN
2. Subtract Coptic epoch (JDN 1825030)
3. Derive Coptic year, month, day from remainder

Coptic year has 12 months of 30 days + 1 intercalary month (Nasie) of 5 or 6 days.

### Coptic Easter (Butcher's Algorithm)

1. Compute Julian Easter using Butcher's algorithm on the Coptic year
2. Add 13-day Julian→Gregorian offset
3. Result is Gregorian Easter Sunday

### Moveable Feasts

All derived from Easter:
```
feast_date = easter_date + easter_offset (days)
```

Key offsets:
| Feast             | Offset |
|-------------------|--------|
| Nineveh Fast      | −69    |
| Great Lent start  | −55    |
| Palm Sunday       | −7     |
| Easter            | 0      |
| Ascension         | +39    |
| Pentecost         | +49    |

---

## Testing Strategy

- All 6 test suites read `core/test-vectors.json` directly
- Tests are data-driven: iterate vectors, assert outputs
- Each language uses its most popular test framework (see table above)
- CI runs all 6 test suites on push
