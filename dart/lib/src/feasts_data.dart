/// Static metadata for a feast (mirror of one entry in core/feasts.json).
class FeastRecord {
  final String id;
  final Map<String, String> names;
  final String type;
  final String category;
  final int? copticMonth;
  final int? copticDay;
  final int? easterOffset;

  const FeastRecord({
    required this.id,
    required this.names,
    required this.type,
    required this.category,
    this.copticMonth,
    this.copticDay,
    this.easterOffset,
  });
}

/// Hand-maintained mirror of core/feasts.json. Keep order identical for test parity.
const List<FeastRecord> kFeasts = [
  FeastRecord(
    id: 'nativity',
    names: {'en': 'Nativity of Christ', 'ar': 'عيد الميلاد المجيد'},
    type: 'fixed', category: 'major',
    copticMonth: 4, copticDay: 29,
  ),
  FeastRecord(
    id: 'epiphany',
    names: {'en': 'Epiphany (Theophany)', 'ar': 'عيد الغطاس'},
    type: 'fixed', category: 'major',
    copticMonth: 5, copticDay: 11,
  ),
  FeastRecord(
    id: 'annunciation',
    names: {'en': 'Annunciation', 'ar': 'عيد البشارة'},
    type: 'fixed', category: 'major',
    copticMonth: 7, copticDay: 29,
  ),
  FeastRecord(
    id: 'assumption',
    names: {'en': 'Assumption of Mary', 'ar': 'عيد انتقال العذراء'},
    type: 'fixed', category: 'major',
    copticMonth: 12, copticDay: 16,
  ),
  FeastRecord(
    id: 'cross',
    names: {'en': 'Feast of the Cross', 'ar': 'عيد الصليب'},
    type: 'fixed', category: 'major',
    copticMonth: 1, copticDay: 17,
  ),
  FeastRecord(
    id: 'nineveh_fast',
    names: {'en': 'Nineveh Fast', 'ar': 'صوم نينوى'},
    type: 'moveable', category: 'major',
    easterOffset: -69,
  ),
  FeastRecord(
    id: 'great_lent',
    names: {'en': 'Great Lent (start)', 'ar': 'بداية الصوم الكبير'},
    type: 'moveable', category: 'major',
    easterOffset: -55,
  ),
  FeastRecord(
    id: 'palm_sunday',
    names: {'en': 'Palm Sunday', 'ar': 'أحد الشعانين'},
    type: 'moveable', category: 'major',
    easterOffset: -7,
  ),
  FeastRecord(
    id: 'easter',
    names: {'en': 'Easter Sunday', 'ar': 'عيد القيامة المجيد'},
    type: 'moveable', category: 'major',
    easterOffset: 0,
  ),
  FeastRecord(
    id: 'ascension',
    names: {'en': 'Ascension', 'ar': 'عيد الصعود'},
    type: 'moveable', category: 'major',
    easterOffset: 39,
  ),
  FeastRecord(
    id: 'pentecost',
    names: {'en': 'Pentecost', 'ar': 'عيد العنصرة'},
    type: 'moveable', category: 'major',
    easterOffset: 49,
  ),
];

/// Look up a feast record by id. Throws if not found.
FeastRecord feastById(String id) {
  for (final f in kFeasts) {
    if (f.id == id) return f;
  }
  throw ArgumentError('unknown feast id: "$id"');
}
