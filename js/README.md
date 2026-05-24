<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (JavaScript / TypeScript)

Coptic calendar arithmetic — date conversion, Easter, and feast days. The reference port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

Works in **Node.js and the browser** — no Node-only APIs at runtime.

**Live demo:** <https://raw.githack.com/amir-magdy-of-wizardlabz/kiahk/master/demo/index.html>

## Install

```bash
npm install kiahk
```

Or from this repo for development:

```bash
cd js
npm install
npm run build
npm test
```

## Quick start

```js
import { CopticDate, GregorianDate, CopticCalendar } from 'kiahk'

// Convert Gregorian → Coptic
const g = new GregorianDate(2025, 1, 11)
const c = g.toCoptic()
console.log(c.year, c.month, c.day) // 1741 5 3

// Convert Coptic → Gregorian
const c2 = new CopticDate(1742, 1, 1)
const g2 = c2.toGregorian()
console.log(g2.year, g2.month, g2.day) // 2025 9 11

// Coptic Easter for a Gregorian year
const easter = CopticCalendar.easterDate(2025)
console.log(easter.year, easter.month, easter.day) // 2025 4 20

// All major feasts for a Gregorian year, sorted by date
for (const feast of CopticCalendar.yearFeasts(2025)) {
  const d = feast.gregorianDate
  const pad = n => String(n).padStart(2, '0')
  console.log(`${d.year}-${pad(d.month)}-${pad(d.day)}  ${feast.name('en')}`)
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

The library exposes Coptic month names in `en` + `ar` via `CopticCalendar.monthName(month, locale)`. The full 13-entry table is also re-exported as `COPTIC_MONTHS` for callers that prefer raw data.

```js
import { GregorianDate, CopticCalendar } from 'kiahk'

const g = new GregorianDate(2025, 4, 20)
const c = g.toCoptic()
console.log(`${c.day} ${CopticCalendar.monthName(c.month, 'en')} ${c.year} AM`)
console.log(`${c.day} ${CopticCalendar.monthName(c.month, 'ar')} ${c.year} للشهداء`)
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / method | Purpose |
| --- | --- |
| `new GregorianDate(y, m, d)` | Validating constructor; throws `InvalidGregorianDateException` on bad input |
| `GregorianDate#toCoptic() → CopticDate` | Convert |
| `GregorianDate#toNativeDate()` / `GregorianDate.fromNativeDate(d)` | Interop with JS `Date` |
| `new CopticDate(y, m, d)` | Validating constructor; throws `InvalidCopticDateException` on bad input |
| `CopticDate#toGregorian() → GregorianDate` | Convert |
| `Feast` | `id`, `type`, `category`, `gregorianDate`, `name(locale)` |
| `feast.name('fr')` | Throws `UnsupportedLocaleException` for unknown locale |
| `CopticCalendar.easterDate(year) → GregorianDate` | Coptic Easter |
| `CopticCalendar.moveableFeast(feastId, year) → Feast` | One moveable feast |
| `CopticCalendar.yearFeasts(year) → Feast[]` | All feasts, sorted ascending |
| `CopticCalendar.monthName(month, locale) → string` | Coptic month name; throws `InvalidCopticMonthException` / `UnsupportedLocaleException` |
| `COPTIC_MONTHS` | 13-entry array (mirrors `core/coptic_months.json`) |

Supported locales for `Feast#name(...)` and `CopticCalendar.monthName(...)`: `en`, `ar`.

## Run tests

```bash
cd js
npm test
```

## License

Licensed under the [MIT License](../LICENSE).

Maintained by Amir Magdy at WizardLabz.
