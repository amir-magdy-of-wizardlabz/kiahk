import 'algorithms.dart';
import 'coptic_months_data.dart';
import 'errors.dart';
import 'feast.dart';
import 'feasts_data.dart';
import 'gregorian_date.dart';

/// Entry points for Easter and feast lookups.
class CopticCalendar {
  CopticCalendar._(); // prevent instantiation

  /// Return the Coptic month name for [month] (1..13) in [locale].
  ///
  /// Throws [InvalidCopticMonthException] if [month] is outside 1..13, and
  /// [UnsupportedLocaleException] if [locale] has no translation.
  static String monthName(int month, String locale) {
    if (month < 1 || month > 13) {
      throw InvalidCopticMonthException(month);
    }
    final record = kCopticMonths[month - 1];
    final name = record.names[locale];
    if (name == null) {
      throw UnsupportedLocaleException('', locale);
    }
    return name;
  }

  /// Return the Gregorian date of Coptic / Orthodox Easter for [gregorianYear].
  static GregorianDate easterDate(int gregorianYear) {
    final r = computeEaster(gregorianYear);
    return GregorianDate(r.year, r.month, r.day);
  }

  /// Resolve a moveable feast (by id) to its Gregorian date in [gregorianYear].
  /// Throws [ArgumentError] if [feastId] is unknown or refers to a fixed feast.
  static Feast moveableFeast(String feastId, int gregorianYear) {
    final rec = feastById(feastId);
    if (rec.type != 'moveable') {
      throw ArgumentError('feast "$feastId" is not moveable');
    }
    final easter = computeEaster(gregorianYear);
    final d = addDays(easter.year, easter.month, easter.day, rec.easterOffset!);
    return Feast(
      id: rec.id,
      type: rec.type,
      category: rec.category,
      names: rec.names,
      gregorianDate: GregorianDate(d.year, d.month, d.day),
    );
  }

  /// Return every feast (fixed + moveable) in [gregorianYear], sorted ascending by date.
  static List<Feast> yearFeasts(int gregorianYear) {
    final out = <Feast>[];
    for (final rec in kFeasts) {
      if (rec.type == 'fixed') {
        out.add(_fixedFeast(rec, gregorianYear));
      } else {
        out.add(moveableFeast(rec.id, gregorianYear));
      }
    }
    out.sort((a, b) {
      if (a.gregorianDate.year != b.gregorianDate.year) {
        return a.gregorianDate.year.compareTo(b.gregorianDate.year);
      }
      if (a.gregorianDate.month != b.gregorianDate.month) {
        return a.gregorianDate.month.compareTo(b.gregorianDate.month);
      }
      return a.gregorianDate.day.compareTo(b.gregorianDate.day);
    });
    return out;
  }

  /// Resolve a fixed Coptic feast to its Gregorian date inside [gregorianYear].
  ///
  /// A Coptic month/day falls in two possible Coptic years that overlap with
  /// the same Gregorian year. Try both candidates, keep the one landing
  /// inside [gregorianYear]; fall back to the earlier candidate.
  static Feast _fixedFeast(FeastRecord rec, int gregorianYear) {
    final cYearA = gregorianToCoptic(gregorianYear, 1, 1).year;
    final cYearB = gregorianToCoptic(gregorianYear, 12, 31).year;
    final candidates = <({int year, int month, int day})>[];
    final seen = <int>{};
    for (final cy in [cYearA, cYearB]) {
      if (!seen.add(cy)) continue;
      final d = copticToGregorian(cy, rec.copticMonth!, rec.copticDay!);
      if (d.year == gregorianYear) candidates.add(d);
    }
    if (candidates.isEmpty) {
      candidates.add(copticToGregorian(cYearA, rec.copticMonth!, rec.copticDay!));
    }
    candidates.sort((a, b) {
      if (a.year != b.year) return a.year.compareTo(b.year);
      if (a.month != b.month) return a.month.compareTo(b.month);
      return a.day.compareTo(b.day);
    });
    final d = candidates.first;
    return Feast(
      id: rec.id,
      type: rec.type,
      category: rec.category,
      names: rec.names,
      gregorianDate: GregorianDate(d.year, d.month, d.day),
    );
  }
}
