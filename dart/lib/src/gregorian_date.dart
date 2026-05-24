import 'errors.dart';

const _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

bool _isGregLeap(int y) => y % 4 == 0 && (y % 100 != 0 || y % 400 == 0);

/// A calendar date on the proleptic Gregorian calendar.
///
/// Immutable value type; constructor validates month/day for the given year.
class GregorianDate {
  final int year;
  final int month;
  final int day;

  /// Construct and validate. Throws [InvalidGregorianDateException] on bad input.
  GregorianDate(this.year, this.month, this.day) {
    if (month < 1 || month > 12) {
      throw InvalidGregorianDateException(
          'month must be 1..12, got $month');
    }
    var maxDay = _daysInMonth[month - 1];
    if (month == 2 && _isGregLeap(year)) maxDay = 29;
    if (day < 1 || day > maxDay) {
      throw InvalidGregorianDateException(
          'day must be 1..$maxDay for $year-${month.toString().padLeft(2, '0')}, got $day');
    }
  }

  /// Construct from a Dart [DateTime] (calendar date only; time-of-day discarded).
  factory GregorianDate.fromDateTime(DateTime dt) =>
      GregorianDate(dt.year, dt.month, dt.day);

  /// Return a [DateTime] at 00:00:00 UTC on this date.
  DateTime toDateTime() => DateTime.utc(year, month, day);

  @override
  bool operator ==(Object other) =>
      other is GregorianDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'GregorianDate($year, $month, $day)';
}
