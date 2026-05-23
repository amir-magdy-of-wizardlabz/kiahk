# kiahk (Go)

Coptic calendar arithmetic — date conversion, Easter, and feast days. Go port of [kiahk](https://github.com/amir-magdy-of-wizardlabz/kiahk). Identical results to all other ports against `core/test-vectors.json`.

## Install

```bash
go get github.com/amir-magdy-of-wizardlabz/kiahk/go
```

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

Supported locales: `en`, `ar`.

**Error pattern** — every typed error (`*InvalidCopticDateError`, `*InvalidGregorianDateError`, `*UnsupportedLocaleError`) wraps a sentinel (`ErrInvalidCopticDate`, `ErrInvalidGregorianDate`, `ErrUnsupportedLocale`). Use `errors.Is(err, kiahk.ErrInvalidCopticDate)` to test kind; type-assert the value to access details.

## Run tests

```bash
cd go
go test ./...
```

## License

MIT
