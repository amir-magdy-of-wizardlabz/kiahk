<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

use Wizardlabz\Kiahk\Exception\InvalidCopticMonthException;
use Wizardlabz\Kiahk\Exception\UnknownFeastException;
use Wizardlabz\Kiahk\Exception\UnsupportedLocaleException;

/** Easter, feast lookups, and Coptic month names. */
final class CopticCalendar
{
    private function __construct() {}

    /**
     * Coptic month name in the requested locale (`'en'` or `'ar'`).
     * @throws InvalidCopticMonthException for month outside 1..13.
     * @throws UnsupportedLocaleException for an unknown locale.
     */
    public static function monthName(int $month, string $locale): string
    {
        if ($month < 1 || $month > 13) {
            throw new InvalidCopticMonthException($month);
        }
        $record = CopticMonths::all()[$month - 1];
        if (!array_key_exists($locale, $record['names'])) {
            throw new UnsupportedLocaleException($locale);
        }
        return $record['names'][$locale];
    }

    /** Coptic Easter (Pascha) for a Gregorian year. */
    public static function easterDate(int $gregorianYear): GregorianDate
    {
        [$y, $m, $d] = Algorithms::computeEaster($gregorianYear);
        return new GregorianDate($y, $m, $d);
    }

    /**
     * One moveable feast for the given Gregorian year.
     * @throws UnknownFeastException if no moveable feast has that id.
     */
    public static function moveableFeast(string $feastId, int $gregorianYear): Feast
    {
        $data = null;
        foreach (Feasts::all() as $entry) {
            if ($entry['id'] === $feastId && $entry['type'] === 'moveable') {
                $data = $entry;
                break;
            }
        }
        if ($data === null) {
            throw new UnknownFeastException($feastId);
        }
        $easter = self::easterDate($gregorianYear);
        [$y, $m, $d] = Algorithms::addDays(
            $easter->year, $easter->month, $easter->day, $data['easter_offset']
        );
        $g = new GregorianDate($y, $m, $d);
        return new Feast($data, $g, $g->toCoptic());
    }

    /**
     * All fixed feasts that fall within the given Gregorian year.
     * A Gregorian year spans two Coptic years, so we check both and dedupe.
     * @return list<Feast>
     */
    public static function fixedFeasts(int $gregorianYear): array
    {
        $cYearStart = (new GregorianDate($gregorianYear, 1, 1))->toCoptic()->year;
        $result = [];
        $seen = [];
        foreach ([$cYearStart, $cYearStart + 1] as $cYear) {
            foreach (Feasts::all() as $entry) {
                if ($entry['type'] !== 'fixed') {
                    continue;
                }
                try {
                    $c = new CopticDate($cYear, $entry['coptic_month'], $entry['coptic_day']);
                    $g = $c->toGregorian();
                    if ($g->year === $gregorianYear && !isset($seen[$entry['id']])) {
                        $seen[$entry['id']] = true;
                        $result[] = new Feast($entry, $g, $c);
                    }
                } catch (\InvalidArgumentException) {
                    // Invalid date for this coptic year (e.g. month 13 day 6 in non-leap) — skip.
                }
            }
        }
        return $result;
    }

    /**
     * All major feasts (fixed + moveable) in the given Gregorian year,
     * sorted ascending by Gregorian date.
     * @return list<Feast>
     */
    public static function yearFeasts(int $gregorianYear): array
    {
        $moveable = [];
        foreach (Feasts::all() as $entry) {
            if ($entry['type'] === 'moveable') {
                $moveable[] = self::moveableFeast($entry['id'], $gregorianYear);
            }
        }
        $all = array_merge(self::fixedFeasts($gregorianYear), $moveable);
        usort($all, function (Feast $a, Feast $b): int {
            $ad = $a->gregorianDate;
            $bd = $b->gregorianDate;
            return Algorithms::gregorianToJdn($ad->year, $ad->month, $ad->day)
                <=> Algorithms::gregorianToJdn($bd->year, $bd->month, $bd->day);
        });
        return $all;
    }
}
