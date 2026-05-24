/// Kiahk — Coptic calendar arithmetic.
///
/// Date conversion (Gregorian ↔ Coptic), Easter computation, fixed and
/// moveable feast lookup, with localized names (en/ar). Identical results
/// to all sibling ports against `core/test-vectors.json`.
library;

export 'src/errors.dart';
export 'src/algorithms.dart';
export 'src/gregorian_date.dart';
export 'src/coptic_date.dart';
export 'src/feasts_data.dart';
export 'src/feast.dart';
export 'src/coptic_calendar.dart';
