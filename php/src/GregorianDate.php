<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

use DateTimeImmutable;
use Wizardlabz\Kiahk\Exception\InvalidGregorianDateException;

/** A calendar date on the proleptic Gregorian calendar. */
final class GregorianDate
{
    public function __construct(
        public readonly int $year,
        public readonly int $month,
        public readonly int $day,
    ) {
        if ($month < 1 || $month > 12) {
            throw new InvalidGregorianDateException($year, $month, $day);
        }
        if ($day < 1 || $day > self::daysInMonth($year, $month)) {
            throw new InvalidGregorianDateException($year, $month, $day);
        }
    }

    /** Convert this Gregorian date to a Coptic date. */
    public function toCoptic(): CopticDate
    {
        [$cy, $cm, $cd] = Algorithms::jdnToCoptic(
            Algorithms::gregorianToJdn($this->year, $this->month, $this->day)
        );
        return new CopticDate($cy, $cm, $cd);
    }

    /** Interop with PHP's DateTimeImmutable (UTC midnight). */
    public function toDateTimeImmutable(): DateTimeImmutable
    {
        return new DateTimeImmutable(sprintf(
            '%04d-%02d-%02dT00:00:00+00:00',
            $this->year, $this->month, $this->day
        ));
    }

    /** Build a GregorianDate from a DateTimeImmutable (uses the date part only). */
    public static function fromDateTimeImmutable(DateTimeImmutable $dt): self
    {
        return new self(
            (int) $dt->format('Y'),
            (int) $dt->format('n'),
            (int) $dt->format('j'),
        );
    }

    public function equals(GregorianDate $other): bool
    {
        return $this->year === $other->year
            && $this->month === $other->month
            && $this->day === $other->day;
    }

    public function __toString(): string
    {
        return sprintf('GregorianDate(%d, %d, %d)', $this->year, $this->month, $this->day);
    }

    /** Days-in-month accounting for Gregorian leap rule. */
    private static function daysInMonth(int $year, int $month): int
    {
        return match ($month) {
            1, 3, 5, 7, 8, 10, 12 => 31,
            4, 6, 9, 11           => 30,
            2                     => self::isLeap($year) ? 29 : 28,
            default               => 0,
        };
    }

    /** Gregorian leap year: divisible by 4, except centuries not divisible by 400. */
    private static function isLeap(int $year): bool
    {
        return ($year % 4 === 0 && $year % 100 !== 0) || $year % 400 === 0;
    }
}
