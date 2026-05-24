<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

/**
 * Coptic month-name table — hand-maintained mirror of core/coptic_months.json.
 * Keep order identical (months 1..13) for cross-port test parity.
 */
final class CopticMonths
{
    private function __construct() {}

    /**
     * 13 month records in order.
     *
     * @return list<array{month:int,names:array<string,string>}>
     */
    public static function all(): array
    {
        return [
            ['month' => 1,  'names' => ['en' => 'Thout',    'ar' => 'توت']],
            ['month' => 2,  'names' => ['en' => 'Paopi',    'ar' => 'بابة']],
            ['month' => 3,  'names' => ['en' => 'Hathor',   'ar' => 'هاتور']],
            ['month' => 4,  'names' => ['en' => 'Koiak',    'ar' => 'كيهك']],
            ['month' => 5,  'names' => ['en' => 'Tobi',     'ar' => 'طوبة']],
            ['month' => 6,  'names' => ['en' => 'Meshir',   'ar' => 'أمشير']],
            ['month' => 7,  'names' => ['en' => 'Paremhat', 'ar' => 'برمهات']],
            ['month' => 8,  'names' => ['en' => 'Parmouti', 'ar' => 'برمودة']],
            ['month' => 9,  'names' => ['en' => 'Pashons',  'ar' => 'بشنس']],
            ['month' => 10, 'names' => ['en' => 'Paoni',    'ar' => 'بؤونة']],
            ['month' => 11, 'names' => ['en' => 'Epip',     'ar' => 'أبيب']],
            ['month' => 12, 'names' => ['en' => 'Mesori',   'ar' => 'مسرى']],
            ['month' => 13, 'names' => ['en' => 'Nasie',    'ar' => 'نسيء']],
        ];
    }
}
