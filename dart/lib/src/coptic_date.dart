import 'algorithms.dart';
import 'errors.dart';
import 'gregorian_date.dart';

// Coptic months 1..12 have 30 days. Month 13 (Nasie) has 5 days, or 6 in a
// leap year. Coptic leap year rule: Y mod 4 == 3 (Julian-style).
bool _isCopticLeap(int y) => y % 4 == 3;

/// A calendar date on the Coptic (Anno Martyrum) calendar.
class CopticDate {
  final int year;
  final int month;
  final int day;

  /// Construct and validate. Throws [InvalidCopticDateException] on bad input.
  CopticDate(this.year, this.month, this.day) {
    if (month < 1 || month > 13) {
      throw InvalidCopticDateException(
          'coptic month must be 1..13, got $month');
    }
    int maxDay = 30;
    if (month == 13) {
      maxDay = _isCopticLeap(year) ? 6 : 5;
    }
    if (day < 1 || day > maxDay) {
      throw InvalidCopticDateException(
          'coptic day must be 1..$maxDay for year $year month $month, got $day');
    }
  }

  /// Convert this Coptic date to a Gregorian date.
  GregorianDate toGregorian() {
    final r = copticToGregorian(year, month, day);
    return GregorianDate(r.year, r.month, r.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CopticDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'CopticDate($year, $month, $day)';
}

/// Extension on [GregorianDate] that adds `toCoptic()`. Lives here so that
/// `gregorian_date.dart` can be loaded without referencing `CopticDate`.
extension GregorianToCopticExtension on GregorianDate {
  /// Convert this Gregorian date to a Coptic date.
  CopticDate toCoptic() {
    final r = gregorianToCoptic(year, month, day);
    return CopticDate(r.year, r.month, r.day);
  }
}
