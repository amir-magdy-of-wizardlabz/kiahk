<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

/**
 * Calendar conversion primitives for the Coptic (Alexandrian) calendar.
 * Identical results to the JS / Python / Go / Dart / Swift / C# / C ports
 * against core/test-vectors.json. See core/algorithms.md for the spec.
 */
final class Algorithms
{
    /** JDN of 1 Tout, year 1 AM (Coptic epoch). */
    public const COPTIC_EPOCH = 1825030;

    private function __construct() {}

    /** Gregorian date → Julian Day Number (Fliegel & Van Flandern). */
    public static function gregorianToJdn(int $year, int $month, int $day): int
    {
        $a = intdiv(14 - $month, 12);
        $y = $year + 4800 - $a;
        $m = $month + 12 * $a - 3;
        return $day
            + intdiv(153 * $m + 2, 5)
            + 365 * $y
            + intdiv($y, 4) - intdiv($y, 100) + intdiv($y, 400)
            - 32045;
    }

    /**
     * Julian Day Number → Gregorian date.
     * @return array{0:int,1:int,2:int} [year, month, day]
     */
    public static function jdnToGregorian(int $jdn): array
    {
        $a = $jdn + 32044;
        $b = intdiv(4 * $a + 3, 146097);
        $c = $a - intdiv(146097 * $b, 4);
        $d = intdiv(4 * $c + 3, 1461);
        $e = $c - intdiv(1461 * $d, 4);
        $m = intdiv(5 * $e + 2, 153);
        $day = $e - intdiv(153 * $m + 2, 5) + 1;
        $month = $m + 3 - 12 * intdiv($m, 10);
        $year = 100 * $b + $d - 4800 + intdiv($m, 10);
        return [$year, $month, $day];
    }

    /** Coptic date → Julian Day Number. */
    public static function copticToJdn(int $cYear, int $cMonth, int $cDay): int
    {
        return self::COPTIC_EPOCH - 1
            + 365 * ($cYear - 1)
            + intdiv($cYear, 4)
            + 30 * ($cMonth - 1)
            + $cDay;
    }

    /**
     * Julian Day Number → Coptic date.
     * @return array{0:int,1:int,2:int} [cYear, cMonth, cDay]
     */
    public static function jdnToCoptic(int $jdn): array
    {
        $r = $jdn - self::COPTIC_EPOCH;
        $cYear = intdiv(4 * $r + 1463, 1461);
        $dayOfYr = $r - 365 * ($cYear - 1) - intdiv($cYear, 4);
        $cMonth = intdiv($dayOfYr, 30) + 1;
        $cDay = $dayOfYr - 30 * ($cMonth - 1) + 1;
        return [$cYear, $cMonth, $cDay];
    }

    /**
     * Coptic Easter (Pascha) for a Gregorian year.
     * Julian computus (Meeus) + +13 Julian→Gregorian shift, valid 1900-03-01..2100-02-28.
     * @return array{0:int,1:int,2:int} [year, month, day] (Gregorian)
     */
    public static function computeEaster(int $gregorianYear): array
    {
        $a = $gregorianYear % 4;
        $b = $gregorianYear % 7;
        $c = $gregorianYear % 19;
        $d = (19 * $c + 15) % 30;
        $e = (2 * $a + 4 * $b - $d + 34) % 7;
        // PHP's % preserves sign of dividend, but $e is always >= 0 here because
        // the +34 ensures the numerator is positive for all gregorianYear >= 0.
        $f = intdiv($d + $e + 114, 31);
        $g = (($d + $e + 114) % 31) + 1;
        $jdn = self::gregorianToJdn($gregorianYear, $f, $g) + 13;
        return self::jdnToGregorian($jdn);
    }

    /**
     * Add `days` to a Gregorian date.
     * @return array{0:int,1:int,2:int} [year, month, day]
     */
    public static function addDays(int $year, int $month, int $day, int $days): array
    {
        return self::jdnToGregorian(self::gregorianToJdn($year, $month, $day) + $days);
    }
}
