<p align="center">
  <img src="https://raw.githubusercontent.com/amir-magdy-of-wizardlabz/kiahk/master/assets/kiahk.png" alt="Kiahk logo" width="160">
</p>

# kiahk (Go)

[![Go Reference](https://pkg.go.dev/badge/github.com/amir-magdy-of-wizardlabz/kiahk/go.svg)](https://pkg.go.dev/github.com/amir-magdy-of-wizardlabz/kiahk/go)
[![Go Report Card](https://goreportcard.com/badge/github.com/amir-magdy-of-wizardlabz/kiahk/go)](https://goreportcard.com/report/github.com/amir-magdy-of-wizardlabz/kiahk/go)
[![license](https://img.shields.io/github/license/amir-magdy-of-wizardlabz/kiahk.svg)](../LICENSE)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Go port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

**Package:** <https://pkg.go.dev/github.com/amir-magdy-of-wizardlabz/kiahk/go>

## Install

```bash
go get github.com/amir-magdy-of-wizardlabz/kiahk/go
```

Released via subdirectory-prefixed tags (e.g. `go/v0.1.3`). `go get` resolves the latest automatically.

## Quick start

```go
package main

import (
	"fmt"

	kiahk "github.com/amir-magdy-of-wizardlabz/kiahk/go"
)

func main() {
	// Convert Gregorian → Coptic
	g, _ := kiahk.NewGregorianDate(2025, 1, 11)
	c := g.ToCoptic()
	fmt.Println(c.Year, c.Month, c.Day) // 1741 5 3

	// Convert Coptic → Gregorian
	c2, _ := kiahk.NewCopticDate(1742, 1, 1)
	g2 := c2.ToGregorian()
	fmt.Println(g2.Year, g2.Month, g2.Day) // 2025 9 11

	// Coptic Easter for a Gregorian year
	easter := kiahk.EasterDate(2025)
	fmt.Println(easter.Year, easter.Month, easter.Day) // 2025 4 20

	// All major feasts for a Gregorian year, sorted by date
	for _, feast := range kiahk.YearFeasts(2025) {
		name, _ := feast.Name("en")
		g := feast.GregorianDate
		fmt.Printf("%d-%02d-%02d  %s\n", g.Year, g.Month, g.Day, name)
	}
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

The library exposes Coptic month names in `en` + `ar` via `kiahk.CopticMonthName(month, locale)`. The full 13-entry table is also re-exported as `kiahk.CopticMonths` for callers that prefer raw data.

```go
package main

import (
	"fmt"

	kiahk "github.com/amir-magdy-of-wizardlabz/kiahk/go"
)

func main() {
	g, _ := kiahk.NewGregorianDate(2025, 4, 20)
	c := g.ToCoptic()
	en, _ := kiahk.CopticMonthName(c.Month, "en")
	ar, _ := kiahk.CopticMonthName(c.Month, "ar")
	fmt.Printf("%d %s %d AM\n", c.Day, en, c.Year)
	fmt.Printf("%d %s %d للشهداء\n", c.Day, ar, c.Year)
}
```

**Sample output:**

```
12 Parmouti 1741 AM
12 برمودة 1741 للشهداء
```

## API at a glance

| Type / function | Purpose |
| --- | --- |
| `NewGregorianDate(y, m, d) (GregorianDate, error)` | Validating constructor; error wraps `ErrInvalidGregorianDate` |
| `(g GregorianDate) ToCoptic() CopticDate` | Convert |
| `(g GregorianDate) ToTime() time.Time` | UTC `time.Time` interop |
| `GregorianDateFromTime(t time.Time) GregorianDate` | Construct from `time.Time` |
| `NewCopticDate(y, m, d) (CopticDate, error)` | Validating constructor; error wraps `ErrInvalidCopticDate` |
| `(c CopticDate) ToGregorian() GregorianDate` | Convert |
| `Feast` | `ID`, `Type`, `Category`, `Names`, `GregorianDate`, `Name(locale)` |
| `(f Feast) Name(locale) (string, error)` | Localized name; unknown locale wraps `ErrUnsupportedLocale` |
| `EasterDate(year int) GregorianDate` | Coptic Easter on the Gregorian calendar |
| `MoveableFeast(id string, year int) (Feast, error)` | One moveable feast |
| `YearFeasts(year int) []Feast` | All feasts in the year, sorted ascending |
| `CopticMonthName(month int, locale string) (string, error)` | Coptic month name; errors wrap `ErrInvalidCopticMonth` / `ErrUnsupportedLocale` |
| `CopticMonths []CopticMonthRecord` | 13-entry table (mirrors `core/coptic_months.json`) |

Supported locales: `en`, `ar`.

**Error pattern** — every typed error (`*InvalidCopticDateError`, `*InvalidGregorianDateError`, `*UnsupportedLocaleError`, `*InvalidCopticMonthError`) wraps a sentinel (`ErrInvalidCopticDate`, `ErrInvalidGregorianDate`, `ErrUnsupportedLocale`, `ErrInvalidCopticMonth`). Use `errors.Is(err, kiahk.ErrInvalidCopticDate)` to test kind; type-assert the value to access details.

## Run tests

```bash
cd go
go test ./...
```

## License

Licensed under the [MIT License](../LICENSE).

Maintained by Amir Magdy at WizardLabz.
