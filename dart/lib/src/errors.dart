/// Thrown when a [CopticDate] is constructed with out-of-range month/day.
class InvalidCopticDateException implements Exception {
  final String message;
  InvalidCopticDateException(this.message);
  @override
  String toString() => 'InvalidCopticDateException: $message';
}

/// Thrown when a [GregorianDate] is constructed with out-of-range month/day.
class InvalidGregorianDateException implements Exception {
  final String message;
  InvalidGregorianDateException(this.message);
  @override
  String toString() => 'InvalidGregorianDateException: $message';
}

/// Thrown when [Feast.name] is asked for a locale with no translation.
class UnsupportedLocaleException implements Exception {
  final String feastId;
  final String locale;
  UnsupportedLocaleException(this.feastId, this.locale);
  @override
  String toString() =>
      'UnsupportedLocaleException: feast "$feastId" has no name for locale "$locale"';
}

/// Thrown when a Coptic month outside 1..13 is passed to a month-name lookup.
class InvalidCopticMonthException implements Exception {
  final int month;
  InvalidCopticMonthException(this.month);
  @override
  String toString() =>
      'InvalidCopticMonthException: invalid Coptic month $month (expected 1..13)';
}
