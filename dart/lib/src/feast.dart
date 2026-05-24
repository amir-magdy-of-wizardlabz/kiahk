import 'errors.dart';
import 'gregorian_date.dart';

/// A calendar-resolved feast: a [FeastRecord]'s metadata paired with the
/// [GregorianDate] on which it falls for a particular year.
class Feast {
  final String id;
  final String type;
  final String category;
  final Map<String, String> names;
  final GregorianDate gregorianDate;

  const Feast({
    required this.id,
    required this.type,
    required this.category,
    required this.names,
    required this.gregorianDate,
  });

  /// Return the feast's localized name for [locale].
  /// Supported locales: 'en', 'ar'. Unknown locales throw [UnsupportedLocaleException].
  String name(String locale) {
    final n = names[locale];
    if (n == null) {
      throw UnsupportedLocaleException(id, locale);
    }
    return n;
  }
}
