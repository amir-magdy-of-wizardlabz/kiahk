import 'dart:convert';
import 'dart:io';

import 'package:kiahk/kiahk.dart';
import 'package:test/test.dart';

// ----------------------------------------------------------------------
// Shared test-vector loader (parsed once at file load time).
// ----------------------------------------------------------------------

final Map<String, dynamic> vectors = jsonDecode(
  File('../core/test-vectors.json').readAsStringSync(),
) as Map<String, dynamic>;

List<Map<String, dynamic>> _vecList(String key) =>
    (vectors[key] as List<dynamic>).cast<Map<String, dynamic>>();

void main() {
  group('errors', () {
    test('InvalidCopticDateException is throwable and is Exception', () {
      expect(
        () => throw InvalidCopticDateException('bad'),
        throwsA(isA<InvalidCopticDateException>()),
      );
      expect(InvalidCopticDateException('bad'), isA<Exception>());
    });

    test('InvalidGregorianDateException is throwable and is Exception', () {
      expect(
        () => throw InvalidGregorianDateException('bad'),
        throwsA(isA<InvalidGregorianDateException>()),
      );
      expect(InvalidGregorianDateException('bad'), isA<Exception>());
    });

    test('UnsupportedLocaleException is throwable and is Exception', () {
      expect(
        () => throw UnsupportedLocaleException('easter', 'fr'),
        throwsA(isA<UnsupportedLocaleException>()),
      );
      expect(UnsupportedLocaleException('easter', 'fr'), isA<Exception>());
    });
  });

  group('algorithms / gregorianToJdn', () {
    test('known JDN values', () {
      expect(gregorianToJdn(2000, 1, 1), 2451545);
      expect(gregorianToJdn(1900, 1, 1), 2415021);
      expect(gregorianToJdn(2025, 1, 11), 2460687);
    });
  });

  group('algorithms / jdnToGregorian + round trip', () {
    test('round trip preserves date', () {
      for (final ymd in const [
        [2000, 1, 1],
        [1900, 1, 1],
        [2025, 1, 11],
        [2024, 12, 25],
        [2025, 9, 11],
      ]) {
        final jdn = gregorianToJdn(ymd[0], ymd[1], ymd[2]);
        final r = jdnToGregorian(jdn);
        expect((r.year, r.month, r.day), (ymd[0], ymd[1], ymd[2]),
            reason: 'round trip $ymd');
      }
    });
  });

  group('algorithms / copticToJdn', () {
    test('1 Tout 1 AM is JDN 1825030', () {
      expect(copticToJdn(1, 1, 1), 1825030);
    });
  });

  group('algorithms / jdnToCoptic round trip', () {
    test('every coptic vector round-trips through JDN', () {
      for (final vec in _vecList('gregorian_to_coptic')) {
        final c = vec['coptic'] as Map<String, dynamic>;
        final jdn = copticToJdn(c['year'] as int, c['month'] as int, c['day'] as int);
        final r = jdnToCoptic(jdn);
        expect((r.year, r.month, r.day),
            (c['year'] as int, c['month'] as int, c['day'] as int),
            reason: 'coptic round trip $c');
      }
    });
  });

  group('algorithms / gregorianToCoptic vectors', () {
    for (final vec in _vecList('gregorian_to_coptic')) {
      final g = vec['gregorian'] as Map<String, dynamic>;
      final c = vec['coptic'] as Map<String, dynamic>;
      test('Gregorian $g → Coptic $c', () {
        final r = gregorianToCoptic(g['year'] as int, g['month'] as int, g['day'] as int);
        expect((r.year, r.month, r.day),
            (c['year'] as int, c['month'] as int, c['day'] as int));
      });
    }
  });

  group('algorithms / copticToGregorian vectors', () {
    for (final vec in _vecList('coptic_to_gregorian')) {
      final c = vec['coptic'] as Map<String, dynamic>;
      final g = vec['gregorian'] as Map<String, dynamic>;
      test('Coptic $c → Gregorian $g', () {
        final r = copticToGregorian(c['year'] as int, c['month'] as int, c['day'] as int);
        expect((r.year, r.month, r.day),
            (g['year'] as int, g['month'] as int, g['day'] as int));
      });
    }
  });

  group('algorithms / computeEaster vectors', () {
    for (final vec in _vecList('easter')) {
      final year = vec['gregorian_year'] as int;
      final d = vec['date'] as Map<String, dynamic>;
      test('Easter $year', () {
        final r = computeEaster(year);
        expect((r.year, r.month, r.day),
            (d['year'] as int, d['month'] as int, d['day'] as int));
      });
    }
  });

  group('algorithms / addDays', () {
    test('known offsets', () {
      final a = addDays(2025, 1, 1, 10);
      expect((a.year, a.month, a.day), (2025, 1, 11));
      final b = addDays(2025, 1, 1, -1);
      expect((b.year, b.month, b.day), (2024, 12, 31));
      // 2024 is a leap year
      final c = addDays(2024, 2, 28, 1);
      expect((c.year, c.month, c.day), (2024, 2, 29));
    });
  });

  group('GregorianDate', () {
    test('basic construction', () {
      final g = GregorianDate(2025, 1, 11);
      expect((g.year, g.month, g.day), (2025, 1, 11));
    });

    test('rejects invalid dates from vectors', () {
      for (final bad in _vecList('invalid_gregorian_dates')) {
        expect(
          () => GregorianDate(bad['year'] as int, bad['month'] as int, bad['day'] as int),
          throwsA(isA<InvalidGregorianDateException>()),
          reason: 'should reject $bad',
        );
      }
    });

    test('toDateTime returns midnight UTC on that calendar date', () {
      final g = GregorianDate(2025, 1, 11);
      final dt = g.toDateTime();
      expect(dt.year, 2025);
      expect(dt.month, 1);
      expect(dt.day, 11);
      expect(dt.isUtc, true);
    });

    test('fromDateTime extracts calendar date', () {
      final g = GregorianDate.fromDateTime(DateTime.utc(2025, 1, 11, 12, 34, 56));
      expect((g.year, g.month, g.day), (2025, 1, 11));
    });

    test('equality is value-based', () {
      expect(GregorianDate(2025, 1, 11), equals(GregorianDate(2025, 1, 11)));
      expect(GregorianDate(2025, 1, 11).hashCode,
          equals(GregorianDate(2025, 1, 11).hashCode));
    });
  });

  group('CopticDate', () {
    test('basic construction', () {
      final c = CopticDate(1741, 5, 3);
      expect((c.year, c.month, c.day), (1741, 5, 3));
    });

    test('rejects invalid dates from vectors', () {
      for (final bad in _vecList('invalid_coptic_dates')) {
        expect(
          () => CopticDate(bad['year'] as int, bad['month'] as int, bad['day'] as int),
          throwsA(isA<InvalidCopticDateException>()),
          reason: 'should reject $bad',
        );
      }
    });

    test('toGregorian converts known date', () {
      final c = CopticDate(1741, 5, 3);
      final g = c.toGregorian();
      expect((g.year, g.month, g.day), (2025, 1, 11));
    });

    test('GregorianDate.toCoptic converts known date', () {
      final g = GregorianDate(2025, 1, 11);
      final c = g.toCoptic();
      expect((c.year, c.month, c.day), (1741, 5, 3));
    });
  });

  group('feasts data parity', () {
    test('matches core/feasts.json exactly', () {
      final core = (jsonDecode(File('../core/feasts.json').readAsStringSync())
              as List<dynamic>)
          .cast<Map<String, dynamic>>();
      expect(kFeasts.length, core.length);
      for (var i = 0; i < kFeasts.length; i++) {
        final f = kFeasts[i];
        final ref = core[i];
        expect(f.id, ref['id'], reason: 'id [$i]');
        expect(f.type, ref['type'], reason: 'type [$i]');
        expect(f.category, ref['category'], reason: 'category [$i]');
        final refNames = ref['names'] as Map<String, dynamic>;
        expect(f.names['en'], refNames['en'], reason: 'en [$i]');
        expect(f.names['ar'], refNames['ar'], reason: 'ar [$i]');
      }
    });
  });

  group('Feast', () {
    test('basic fields and localized names', () {
      final feast = Feast(
        id: 'easter',
        type: 'moveable',
        category: 'major',
        names: feastById('easter').names,
        gregorianDate: GregorianDate(2025, 4, 20),
      );
      expect(feast.id, 'easter');
      expect(feast.type, 'moveable');
      expect(feast.category, 'major');
      expect(feast.name('en'), 'Easter Sunday');
      expect(feast.name('ar'), 'عيد القيامة المجيد');
    });

    test('unknown locale throws UnsupportedLocaleException', () {
      final feast = Feast(
        id: 'easter',
        type: 'moveable',
        category: 'major',
        names: feastById('easter').names,
        gregorianDate: GregorianDate(2025, 4, 20),
      );
      expect(() => feast.name('fr'),
          throwsA(isA<UnsupportedLocaleException>()));
    });
  });

  group('CopticCalendar.easterDate vectors', () {
    for (final vec in _vecList('easter')) {
      final year = vec['gregorian_year'] as int;
      final d = vec['date'] as Map<String, dynamic>;
      test('easter $year', () {
        final g = CopticCalendar.easterDate(year);
        expect((g.year, g.month, g.day),
            (d['year'] as int, d['month'] as int, d['day'] as int));
      });
    }
  });

  group('CopticCalendar.moveableFeast vectors', () {
    for (final vec in _vecList('moveable_feasts')) {
      final year = vec['gregorian_year'] as int;
      final id = vec['feast_id'] as String;
      final d = vec['date'] as Map<String, dynamic>;
      test('$id in $year', () {
        final feast = CopticCalendar.moveableFeast(id, year);
        expect(feast.id, id);
        final g = feast.gregorianDate;
        expect((g.year, g.month, g.day),
            (d['year'] as int, d['month'] as int, d['day'] as int));
      });
    }
  });

  group('coptic months data parity', () {
    test('matches core/coptic_months.json exactly', () {
      final core =
          (jsonDecode(File('../core/coptic_months.json').readAsStringSync())
                  as List<dynamic>)
              .cast<Map<String, dynamic>>();
      expect(kCopticMonths.length, core.length);
      for (var i = 0; i < kCopticMonths.length; i++) {
        final m = kCopticMonths[i];
        final ref = core[i];
        expect(m.month, ref['month'], reason: 'month [$i]');
        final refNames = ref['names'] as Map<String, dynamic>;
        expect(m.names['en'], refNames['en'], reason: 'en [$i]');
        expect(m.names['ar'], refNames['ar'], reason: 'ar [$i]');
      }
    });
  });

  group('CopticCalendar.monthName', () {
    for (final vec in _vecList('coptic_month_names')) {
      final month = vec['month'] as int;
      final locale = vec['locale'] as String;
      final name = vec['name'] as String;
      test('month $month locale $locale → $name', () {
        expect(CopticCalendar.monthName(month, locale), name);
      });
    }

    test('rejects invalid month from vectors', () {
      final bad = (vectors['invalid_coptic_months_for_name'] as List<dynamic>)
          .cast<int>();
      for (final m in bad) {
        expect(
          () => CopticCalendar.monthName(m, 'en'),
          throwsA(isA<InvalidCopticMonthException>()),
          reason: 'should reject month $m',
        );
      }
    });

    test('rejects unsupported locale from vectors', () {
      for (final vec in _vecList('invalid_coptic_month_locales')) {
        final m = vec['month'] as int;
        final loc = vec['locale'] as String;
        expect(
          () => CopticCalendar.monthName(m, loc),
          throwsA(isA<UnsupportedLocaleException>()),
          reason: 'should reject locale "$loc" for month $m',
        );
      }
    });
  });

  group('CopticCalendar.yearFeasts', () {
    test('returns non-empty list sorted by date', () {
      final feasts = CopticCalendar.yearFeasts(2025);
      expect(feasts, isNotEmpty);
      for (var i = 1; i < feasts.length; i++) {
        final a = feasts[i - 1].gregorianDate;
        final b = feasts[i].gregorianDate;
        final aTuple = (a.year, a.month, a.day);
        final bTuple = (b.year, b.month, b.day);
        expect(_compareYmd(aTuple, bTuple) <= 0, true,
            reason: 'feasts not sorted at $i: $a > $b');
      }
    });

    test('includes Easter with correct date', () {
      final feasts = CopticCalendar.yearFeasts(2025);
      final easter = feasts.firstWhere((f) => f.id == 'easter');
      final g = easter.gregorianDate;
      expect((g.year, g.month, g.day), (2025, 4, 20));
    });
  });
}

int _compareYmd((int, int, int) a, (int, int, int) b) {
  final (ay, am, ad) = a;
  final (by, bm, bd) = b;
  if (ay != by) return ay.compareTo(by);
  if (am != bm) return am.compareTo(bm);
  return ad.compareTo(bd);
}
