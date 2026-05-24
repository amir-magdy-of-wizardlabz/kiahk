<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (Dart)

[![pub.dev version](https://img.shields.io/pub/v/kiahk.svg)](https://pub.dev/packages/kiahk)
[![pub points](https://img.shields.io/pub/points/kiahk)](https://pub.dev/packages/kiahk/score)
[![pub likes](https://img.shields.io/pub/likes/kiahk)](https://pub.dev/packages/kiahk/score)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Dart port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Package:** <https://pub.dev/packages/kiahk>

## Install

```bash
dart pub add kiahk
```

Or from this repo for development:

```bash
cd dart
dart pub get
```

## Quick start

```dart
import 'package:kiahk/kiahk.dart';

void main() {
  // Convert Gregorian → Coptic
  final g = GregorianDate(2025, 1, 11);
  final c = g.toCoptic();
  print('${c.year} ${c.month} ${c.day}'); // 1741 5 3

  // Convert Coptic → Gregorian
  final c2 = CopticDate(1742, 1, 1);
  final g2 = c2.toGregorian();
  print('${g2.year} ${g2.month} ${g2.day}'); // 2025 9 11

  // Coptic Easter for a Gregorian year
  final easter = CopticCalendar.easterDate(2025);
  print('${easter.year} ${easter.month} ${easter.day}'); // 2025 4 20

  // All major feasts for a Gregorian year, sorted by date
  for (final feast in CopticCalendar.yearFeasts(2025)) {
    final d = feast.gregorianDate;
    print('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  ${feast.name('en')}');
  }
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

The library exposes Coptic month names in `en` + `ar` via `CopticCalendar.monthName(month, locale)`. The full 13-entry table is also re-exported as `kCopticMonths` for callers that prefer raw data.

```dart
import 'package:kiahk/kiahk.dart';

void main() {
  final g = GregorianDate(2025, 4, 20);
  final c = g.toCoptic();
  print('${c.day} ${CopticCalendar.monthName(c.month, 'en')} ${c.year} AM');
  print('${c.day} ${CopticCalendar.monthName(c.month, 'ar')} ${c.year} للشهداء');
}
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `GregorianDate(y, m, d)` | Validating constructor; throws `InvalidGregorianDateException` on bad input |
| `GregorianDate.toCoptic()` → `CopticDate` | Convert (extension method) |
| `GregorianDate.toDateTime()` / `GregorianDate.fromDateTime(dt)` | Interop with `DateTime` |
| `CopticDate(y, m, d)` | Validating constructor; throws `InvalidCopticDateException` on bad input |
| `CopticDate.toGregorian()` → `GregorianDate` | Convert |
| `Feast` | `id`, `type`, `category`, `names`, `gregorianDate`, `name(locale)` |
| `Feast.name('fr')` | Throws `UnsupportedLocaleException` for unknown locale |
| `CopticCalendar.easterDate(year)` → `GregorianDate` | Coptic Easter |
| `CopticCalendar.moveableFeast(feastId, year)` → `Feast` | One moveable feast |
| `CopticCalendar.yearFeasts(year)` → `List<Feast>` | All feasts, sorted ascending |
| `CopticCalendar.monthName(month, locale)` → `String` | Coptic month name; throws `InvalidCopticMonthException` / `UnsupportedLocaleException` |
| `kCopticMonths` | 13-entry `List<CopticMonthRecord>` (mirrors `core/coptic_months.json`) |

Supported locales for `Feast.name(...)` and `CopticCalendar.monthName(...)`: `en`, `ar`.

## Run tests

```bash
cd dart
dart test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
