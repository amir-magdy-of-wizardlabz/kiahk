<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (Dart)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Dart port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

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

Supported locales for `Feast.name(...)`: `en`, `ar`.

## Run tests

```bash
cd dart
dart test
```

## License

Licensed under the [MIT License](LICENSE).

Maintained by Amir Magdy at WizardLabz.
