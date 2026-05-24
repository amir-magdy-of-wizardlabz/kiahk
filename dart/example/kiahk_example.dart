// Runnable example for the kiahk package.
//
// Run from the package root:
//   dart run example/kiahk_example.dart
//
// Or from this directory:
//   dart run kiahk_example.dart

import 'package:kiahk/kiahk.dart';

void main() {
  // 1. Gregorian → Coptic
  final today = GregorianDate(2025, 1, 11);
  final coptic = today.toCoptic();
  print('Gregorian 2025-01-11 → Coptic ${coptic.year}-${coptic.month}-${coptic.day}');
  //  → Coptic 1741-5-3

  // 2. Coptic → Gregorian
  final ny = CopticDate(1742, 1, 1).toGregorian();
  print('Coptic 1742-1-1 (Coptic New Year) → Gregorian ${ny.year}-${ny.month}-${ny.day}');
  //  → Gregorian 2025-9-11

  // 3. Coptic Easter for a Gregorian year
  final easter = CopticCalendar.easterDate(2025);
  print('Coptic Easter 2025 → ${easter.year}-${easter.month}-${easter.day}');
  //  → 2025-4-20

  // 4. Major feasts for a Gregorian year, sorted by date
  print('\nMajor Coptic feasts in 2025:');
  for (final feast in CopticCalendar.yearFeasts(2025)) {
    final d = feast.gregorianDate;
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    print('  ${d.year}-$mm-$dd  ${feast.name('en')}');
  }

  // 5. Coptic month names in English and Arabic
  print('\nCoptic month names:');
  for (var m = 1; m <= 13; m++) {
    final en = CopticCalendar.monthName(m, 'en');
    final ar = CopticCalendar.monthName(m, 'ar');
    print('  $m: $en / $ar');
  }
}
