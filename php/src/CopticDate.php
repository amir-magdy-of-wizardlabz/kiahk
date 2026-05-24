<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

use Wizardlabz\Kiahk\Exception\InvalidCopticDateException;

/** A calendar date on the Coptic (Anno Martyrum) calendar. */
final class CopticDate
{
    public function __construct(
        public readonly int $year,
        public readonly int $month,
        public readonly int $day,
    ) {
        if ($month < 1 || $month > 13) {
            throw new InvalidCopticDateException($year, $month, $day);
        }
        $maxDay = $month === 13
            ? (self::isCopticLeap($year) ? 6 : 5)
            : 30;
        if ($day < 1 || $day > $maxDay) {
            throw new InvalidCopticDateException($year, $month, $day);
        }
    }

    /** Convert this Coptic date to a Gregorian date. */
    public function toGregorian(): GregorianDate
    {
        [$gy, $gm, $gd] = Algorithms::jdnToGregorian(
            Algorithms::copticToJdn($this->year, $this->month, $this->day)
        );
        return new GregorianDate($gy, $gm, $gd);
    }

    public function equals(CopticDate $other): bool
    {
        return $this->year === $other->year
            && $this->month === $other->month
            && $this->day === $other->day;
    }

    public function __toString(): string
    {
        return sprintf('CopticDate(%d, %d, %d)', $this->year, $this->month, $this->day);
    }

    /** Coptic leap year: Y mod 4 == 3 (Julian-style). */
    private static function isCopticLeap(int $year): bool
    {
        return $year % 4 === 3;
    }
}
