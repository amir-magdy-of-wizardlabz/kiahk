<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (PHP)

[![Packagist version](https://img.shields.io/packagist/v/wizardlabz/kiahk.svg)](https://packagist.org/packages/wizardlabz/kiahk)
[![Packagist downloads](https://img.shields.io/packagist/dt/wizardlabz/kiahk.svg)](https://packagist.org/packages/wizardlabz/kiahk)
[![PHP version](https://img.shields.io/packagist/php-v/wizardlabz/kiahk.svg)](https://packagist.org/packages/wizardlabz/kiahk)
[![license](https://img.shields.io/packagist/l/wizardlabz/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. PHP port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

Requires **PHP 8.1+** (uses readonly properties and match expressions).

**Package:** <https://packagist.org/packages/wizardlabz/kiahk>

## Install

```bash
composer require wizardlabz/kiahk
```

Or from this repo for development:

```bash
# composer.json lives at the repo root (canonical Packagist source) — sources
# are in php/src/, tests in php/tests/, run everything from the repo root:
composer install
composer test
```

## Quick start

```php
<?php

require __DIR__ . '/vendor/autoload.php';

use Wizardlabz\Kiahk\CopticCalendar;
use Wizardlabz\Kiahk\CopticDate;
use Wizardlabz\Kiahk\GregorianDate;

// Convert Gregorian → Coptic
$g = new GregorianDate(2025, 1, 11);
$c = $g->toCoptic();
echo "$c->year $c->month $c->day\n"; // 1741 5 3

// Convert Coptic → Gregorian
$c2 = new CopticDate(1742, 1, 1);
$g2 = $c2->toGregorian();
echo "$g2->year $g2->month $g2->day\n"; // 2025 9 11

// Coptic Easter for a Gregorian year
$easter = CopticCalendar::easterDate(2025);
echo "$easter->year $easter->month $easter->day\n"; // 2025 4 20

// All major feasts for a Gregorian year, sorted by date
foreach (CopticCalendar::yearFeasts(2025) as $feast) {
    $d = $feast->gregorianDate;
    printf("%04d-%02d-%02d  %s\n", $d->year, $d->month, $d->day, $feast->name('en'));
}
```

**Sample output:**

```
1741 5 3
2025 9 11
2025 4 20
2025-01-07  Nativity of Christ
2025-01-19  Epiphany (Theophany)
2025-02-10  Nineveh Fast
2025-02-24  Great Lent (start)
2025-04-07  Annunciation
2025-04-13  Palm Sunday
2025-04-20  Easter Sunday
2025-05-29  Ascension
2025-06-08  Pentecost
2025-08-22  Assumption of Mary
2025-09-27  Feast of the Cross
```

## Render a date in English and Arabic

```php
use Wizardlabz\Kiahk\CopticCalendar;
use Wizardlabz\Kiahk\GregorianDate;

$c = (new GregorianDate(2025, 4, 20))->toCoptic();

echo "$c->day " . CopticCalendar::monthName($c->month, 'en') . " $c->year AM\n";
echo "$c->day " . CopticCalendar::monthName($c->month, 'ar') . " $c->year للشهداء\n";
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `new GregorianDate(int $y, int $m, int $d)` | Validating constructor; throws `Exception\InvalidGregorianDateException` on bad input |
| `GregorianDate::toCoptic(): CopticDate` | Convert |
| `GregorianDate::toDateTimeImmutable()` / `::fromDateTimeImmutable(\DateTimeImmutable)` | Interop with PHP's `DateTimeImmutable` |
| `new CopticDate(int $y, int $m, int $d)` | Validating constructor; throws `Exception\InvalidCopticDateException` on bad input |
| `CopticDate::toGregorian(): GregorianDate` | Convert |
| `Feast` | `id()`, `type()`, `category()`, `gregorianDate`, `copticDate`, `name(string $locale)` |
| `Feast::name('fr')` | Throws `Exception\UnsupportedLocaleException` for unknown locale |
| `CopticCalendar::easterDate(int $year): GregorianDate` | Coptic Easter |
| `CopticCalendar::moveableFeast(string $feastId, int $year): Feast` | One moveable feast |
| `CopticCalendar::fixedFeasts(int $year): Feast[]` | Fixed feasts in a Gregorian year |
| `CopticCalendar::yearFeasts(int $year): Feast[]` | All feasts, sorted ascending |
| `CopticCalendar::monthName(int $month, string $locale): string` | Coptic month name; throws `Exception\InvalidCopticMonthException` / `Exception\UnsupportedLocaleException` |

Supported locales for `Feast::name(...)` and `CopticCalendar::monthName(...)`: `en`, `ar`.

## Run tests

```bash
# From repo root (composer.json + phpunit.xml.dist live there)
composer install
composer test
```

## License

Licensed under the [MIT License](../LICENSE).

Maintained by Amir Magdy at WizardLabz.
