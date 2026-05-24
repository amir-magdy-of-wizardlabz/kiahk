package kiahk

import (
	"fmt"
	"sort"
)

// CopticMonthName returns the localized name of Coptic month `month` (1..13)
// in the given locale. It returns *InvalidCopticMonthError (wrapping
// ErrInvalidCopticMonth) for an out-of-range month, and *UnsupportedLocaleError
// (wrapping ErrUnsupportedLocale) for an unknown locale.
func CopticMonthName(month int, locale string) (string, error) {
	if month < 1 || month > 13 {
		return "", &InvalidCopticMonthError{Month: month}
	}
	rec := CopticMonths[month-1]
	name, ok := rec.Names[locale]
	if !ok {
		return "", &UnsupportedLocaleError{FeastID: "", Locale: locale}
	}
	return name, nil
}

// EasterDate returns the Gregorian date of Coptic/Orthodox Easter for the given Gregorian year.
func EasterDate(gregorianYear int) GregorianDate {
	y, m, d := ComputeEaster(gregorianYear)
	g, _ := NewGregorianDate(y, m, d)
	return g
}

// MoveableFeast resolves a moveable feast (by ID) to its Gregorian date in the given year.
// Returns an error if the ID is unknown or refers to a fixed (not moveable) feast.
func MoveableFeast(feastID string, gregorianYear int) (Feast, error) {
	rec, err := FeastByID(feastID)
	if err != nil {
		return Feast{}, err
	}
	if rec.Type != "moveable" {
		return Feast{}, fmt.Errorf("kiahk: feast %q is not moveable", feastID)
	}
	ey, em, ed := ComputeEaster(gregorianYear)
	y, m, d := AddDays(ey, em, ed, rec.EasterOffset)
	g, _ := NewGregorianDate(y, m, d)
	return Feast{
		ID: rec.ID, Type: rec.Type, Category: rec.Category,
		Names: rec.Names, GregorianDate: g,
	}, nil
}

// YearFeasts returns every feast (fixed + moveable) that falls in the given
// Gregorian year, sorted ascending by date.
func YearFeasts(gregorianYear int) []Feast {
	out := make([]Feast, 0, len(Feasts))
	for _, rec := range Feasts {
		if rec.Type == "fixed" {
			out = append(out, fixedFeast(rec, gregorianYear))
		} else {
			f, _ := MoveableFeast(rec.ID, gregorianYear)
			out = append(out, f)
		}
	}
	sort.SliceStable(out, func(i, j int) bool {
		a, b := out[i].GregorianDate, out[j].GregorianDate
		if a.Year != b.Year {
			return a.Year < b.Year
		}
		if a.Month != b.Month {
			return a.Month < b.Month
		}
		return a.Day < b.Day
	})
	return out
}

// fixedFeast resolves a fixed Coptic feast to its Gregorian date inside
// gregorianYear. A Coptic month/day occurs in two possible Coptic years
// that overlap with the same Gregorian year (months early in the Coptic
// year sit in the Coptic year ending in gregorianYear; later months in
// the Coptic year starting in gregorianYear). Try both, keep the one
// landing inside gregorianYear; fall back to the earlier candidate.
func fixedFeast(rec FeastRecord, gregorianYear int) Feast {
	cYearA, _, _ := GregorianToCoptic(gregorianYear, 1, 1)
	cYearB, _, _ := GregorianToCoptic(gregorianYear, 12, 31)
	type cand struct{ y, m, d int }
	var candidates []cand
	seen := map[int]bool{}
	for _, cy := range []int{cYearA, cYearB} {
		if seen[cy] {
			continue
		}
		seen[cy] = true
		y, m, d := CopticToGregorian(cy, rec.CopticMonth, rec.CopticDay)
		if y == gregorianYear {
			candidates = append(candidates, cand{y, m, d})
		}
	}
	if len(candidates) == 0 {
		y, m, d := CopticToGregorian(cYearA, rec.CopticMonth, rec.CopticDay)
		candidates = []cand{{y, m, d}}
	}
	// Earliest candidate wins.
	c := candidates[0]
	for _, x := range candidates[1:] {
		if (x.y < c.y) || (x.y == c.y && x.m < c.m) || (x.y == c.y && x.m == c.m && x.d < c.d) {
			c = x
		}
	}
	g, _ := NewGregorianDate(c.y, c.m, c.d)
	return Feast{
		ID: rec.ID, Type: rec.Type, Category: rec.Category,
		Names: rec.Names, GregorianDate: g,
	}
}
