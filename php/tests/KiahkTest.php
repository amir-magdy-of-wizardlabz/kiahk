<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk\Tests;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wizardlabz\Kiahk\Algorithms;
use Wizardlabz\Kiahk\CopticCalendar;
use Wizardlabz\Kiahk\CopticDate;
use Wizardlabz\Kiahk\Exception\InvalidCopticDateException;
use Wizardlabz\Kiahk\Exception\InvalidCopticMonthException;
use Wizardlabz\Kiahk\Exception\InvalidGregorianDateException;
use Wizardlabz\Kiahk\Exception\UnknownFeastException;
use Wizardlabz\Kiahk\Exception\UnsupportedLocaleException;
use Wizardlabz\Kiahk\GregorianDate;

final class KiahkTest extends TestCase
{
    /** @return array<string,mixed> */
    private static function vectors(): array
    {
        // Load the shared cross-port test contract from core/test-vectors.json.
        // __DIR__ is php/tests/ → ../../core/test-vectors.json (repo root).
        $path = __DIR__ . '/../../core/test-vectors.json';
        $json = file_get_contents($path);
        if ($json === false) {
            throw new \RuntimeException("Failed to read $path");
        }
        return json_decode($json, true, flags: JSON_THROW_ON_ERROR);
    }

    // -------------------------------------------------------------------------
    // gregorian ↔ coptic (data-driven from core/test-vectors.json)
    // -------------------------------------------------------------------------

    public static function gregorianToCopticProvider(): iterable
    {
        foreach (self::vectors()['gregorian_to_coptic'] as $i => $v) {
            yield "vector#$i" => [$v['gregorian'], $v['coptic']];
        }
    }

    #[DataProvider('gregorianToCopticProvider')]
    public function testGregorianToCoptic(array $g, array $expected): void
    {
        $c = (new GregorianDate($g['year'], $g['month'], $g['day']))->toCoptic();
        self::assertSame($expected['year'], $c->year);
        self::assertSame($expected['month'], $c->month);
        self::assertSame($expected['day'], $c->day);
    }

    public static function copticToGregorianProvider(): iterable
    {
        foreach (self::vectors()['coptic_to_gregorian'] as $i => $v) {
            yield "vector#$i" => [$v['coptic'], $v['gregorian']];
        }
    }

    #[DataProvider('copticToGregorianProvider')]
    public function testCopticToGregorian(array $c, array $expected): void
    {
        $g = (new CopticDate($c['year'], $c['month'], $c['day']))->toGregorian();
        self::assertSame($expected['year'], $g->year);
        self::assertSame($expected['month'], $g->month);
        self::assertSame($expected['day'], $g->day);
    }

    // -------------------------------------------------------------------------
    // Round-trip identity over a long range
    // -------------------------------------------------------------------------

    public function testRoundTripGregorianCopticGregorian(): void
    {
        // Sample dates spanning 1900..2099 — every conversion must round-trip.
        $cases = [
            [1900, 1, 1], [1950, 6, 15], [2000, 2, 29], [2024, 12, 31],
            [2025, 1, 11], [2050, 7, 4], [2099, 12, 31],
        ];
        foreach ($cases as [$y, $m, $d]) {
            $g = new GregorianDate($y, $m, $d);
            $roundTrip = $g->toCoptic()->toGregorian();
            self::assertTrue($g->equals($roundTrip), "round-trip failed for $y-$m-$d");
        }
    }

    // -------------------------------------------------------------------------
    // Easter
    // -------------------------------------------------------------------------

    public static function easterProvider(): iterable
    {
        foreach (self::vectors()['easter'] as $v) {
            yield "easter_{$v['gregorian_year']}" => [$v['gregorian_year'], $v['date']];
        }
    }

    #[DataProvider('easterProvider')]
    public function testEaster(int $gYear, array $expected): void
    {
        $easter = CopticCalendar::easterDate($gYear);
        self::assertSame($expected['year'], $easter->year);
        self::assertSame($expected['month'], $easter->month);
        self::assertSame($expected['day'], $easter->day);
    }

    // -------------------------------------------------------------------------
    // Moveable feasts
    // -------------------------------------------------------------------------

    public static function moveableFeastProvider(): iterable
    {
        foreach (self::vectors()['moveable_feasts'] as $i => $v) {
            yield "moveable#$i" => [$v['feast_id'], $v['gregorian_year'], $v['date']];
        }
    }

    #[DataProvider('moveableFeastProvider')]
    public function testMoveableFeast(string $id, int $gYear, array $expected): void
    {
        $feast = CopticCalendar::moveableFeast($id, $gYear);
        $g = $feast->gregorianDate;
        self::assertSame($expected['year'], $g->year);
        self::assertSame($expected['month'], $g->month);
        self::assertSame($expected['day'], $g->day);
        self::assertSame($id, $feast->id());
        self::assertSame('moveable', $feast->type());
    }

    public function testUnknownMoveableFeastThrows(): void
    {
        $this->expectException(UnknownFeastException::class);
        CopticCalendar::moveableFeast('not_a_real_feast', 2025);
    }

    // -------------------------------------------------------------------------
    // Year feasts (full list, sorted)
    // -------------------------------------------------------------------------

    public function testYearFeasts2025IsSortedAndIncludesAllMajor(): void
    {
        $feasts = CopticCalendar::yearFeasts(2025);
        // 6 fixed + 6 moveable (great_lent is in core/feasts.json) — but the
        // exact count depends on which fixed feasts actually land in 2025.
        self::assertGreaterThanOrEqual(11, count($feasts));

        $prev = null;
        foreach ($feasts as $feast) {
            $g = $feast->gregorianDate;
            $jdn = Algorithms::gregorianToJdn($g->year, $g->month, $g->day);
            if ($prev !== null) {
                self::assertGreaterThanOrEqual($prev, $jdn, 'feasts must be sorted ascending');
            }
            $prev = $jdn;
        }

        // Sanity: Easter Sunday must be in the list for 2025
        $ids = array_map(fn($f) => $f->id(), $feasts);
        self::assertContains('easter', $ids);
        self::assertContains('nativity', $ids);
    }

    // -------------------------------------------------------------------------
    // Coptic month names (data-driven where the contract provides them)
    // -------------------------------------------------------------------------

    public static function copticMonthNamesProvider(): iterable
    {
        foreach (self::vectors()['coptic_month_names'] ?? [] as $i => $v) {
            yield "month#$i" => [$v['month'], $v['locale'], $v['name']];
        }
    }

    #[DataProvider('copticMonthNamesProvider')]
    public function testMonthName(int $month, string $locale, string $expected): void
    {
        self::assertSame($expected, CopticCalendar::monthName($month, $locale));
    }

    public function testInvalidMonthThrows(): void
    {
        $this->expectException(InvalidCopticMonthException::class);
        CopticCalendar::monthName(14, 'en');
    }

    public function testUnsupportedLocaleThrows(): void
    {
        $this->expectException(UnsupportedLocaleException::class);
        CopticCalendar::monthName(1, 'fr');
    }

    // -------------------------------------------------------------------------
    // Validation
    // -------------------------------------------------------------------------

    public static function invalidGregorianProvider(): iterable
    {
        foreach (self::vectors()['invalid_gregorian_dates'] as $i => $v) {
            yield "bad_g#$i" => [$v['year'], $v['month'], $v['day']];
        }
    }

    #[DataProvider('invalidGregorianProvider')]
    public function testInvalidGregorianDatesAreRejected(int $y, int $m, int $d): void
    {
        $this->expectException(InvalidGregorianDateException::class);
        new GregorianDate($y, $m, $d);
    }

    public static function invalidCopticProvider(): iterable
    {
        foreach (self::vectors()['invalid_coptic_dates'] as $i => $v) {
            yield "bad_c#$i" => [$v['year'], $v['month'], $v['day']];
        }
    }

    #[DataProvider('invalidCopticProvider')]
    public function testInvalidCopticDatesAreRejected(int $y, int $m, int $d): void
    {
        $this->expectException(InvalidCopticDateException::class);
        new CopticDate($y, $m, $d);
    }

    // -------------------------------------------------------------------------
    // DateTime interop
    // -------------------------------------------------------------------------

    public function testDateTimeImmutableInterop(): void
    {
        $g = new GregorianDate(2025, 1, 11);
        $dt = $g->toDateTimeImmutable();
        self::assertSame('2025-01-11', $dt->format('Y-m-d'));
        self::assertTrue($g->equals(GregorianDate::fromDateTimeImmutable($dt)));
    }
}
