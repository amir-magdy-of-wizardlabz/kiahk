<?php

declare(strict_types=1);

namespace Wizardlabz\Kiahk;

use Wizardlabz\Kiahk\Exception\UnsupportedLocaleException;

/** A feast occurrence in a specific Gregorian year. */
final class Feast
{
    /**
     * @param array{id:string,names:array<string,string>,type:string,category:string,coptic_month?:int,coptic_day?:int,easter_offset?:int} $data
     */
    public function __construct(
        private readonly array $data,
        public readonly GregorianDate $gregorianDate,
        public readonly CopticDate $copticDate,
    ) {}

    public function id(): string
    {
        return $this->data['id'];
    }

    /** 'fixed' or 'moveable'. */
    public function type(): string
    {
        return $this->data['type'];
    }

    /** 'major' for now (kept as a separate field for future expansion). */
    public function category(): string
    {
        return $this->data['category'];
    }

    /** Localized feast name. Supported locales: `'en'`, `'ar'`. */
    public function name(string $locale): string
    {
        if (!array_key_exists($locale, $this->data['names'])) {
            throw new UnsupportedLocaleException($locale);
        }
        return $this->data['names'][$locale];
    }
}
