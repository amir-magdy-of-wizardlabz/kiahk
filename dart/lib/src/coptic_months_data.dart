/// One entry of the Coptic month-name table
/// (mirror of one entry in core/coptic_months.json).
class CopticMonthRecord {
  /// Coptic month number, 1..13.
  final int month;

  /// Localized names of this month, keyed by ISO 639-1 locale code
  /// (e.g. `'en'` → `'Koiak'`, `'ar'` → `'كيهك'`).
  final Map<String, String> names;

  /// Construct a Coptic month record. Both [month] and [names] are required.
  const CopticMonthRecord({required this.month, required this.names});
}

/// Hand-maintained mirror of core/coptic_months.json.
/// Keep order identical (months 1..13) for cross-port test parity.
const List<CopticMonthRecord> kCopticMonths = [
  CopticMonthRecord(month: 1, names: {'en': 'Thout', 'ar': 'توت'}),
  CopticMonthRecord(month: 2, names: {'en': 'Paopi', 'ar': 'بابة'}),
  CopticMonthRecord(month: 3, names: {'en': 'Hathor', 'ar': 'هاتور'}),
  CopticMonthRecord(month: 4, names: {'en': 'Koiak', 'ar': 'كيهك'}),
  CopticMonthRecord(month: 5, names: {'en': 'Tobi', 'ar': 'طوبة'}),
  CopticMonthRecord(month: 6, names: {'en': 'Meshir', 'ar': 'أمشير'}),
  CopticMonthRecord(month: 7, names: {'en': 'Paremhat', 'ar': 'برمهات'}),
  CopticMonthRecord(month: 8, names: {'en': 'Parmouti', 'ar': 'برمودة'}),
  CopticMonthRecord(month: 9, names: {'en': 'Pashons', 'ar': 'بشنس'}),
  CopticMonthRecord(month: 10, names: {'en': 'Paoni', 'ar': 'بؤونة'}),
  CopticMonthRecord(month: 11, names: {'en': 'Epip', 'ar': 'أبيب'}),
  CopticMonthRecord(month: 12, names: {'en': 'Mesori', 'ar': 'مسرى'}),
  CopticMonthRecord(month: 13, names: {'en': 'Nasie', 'ar': 'نسيء'}),
];
