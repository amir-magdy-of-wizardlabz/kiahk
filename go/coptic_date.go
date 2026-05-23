package kiahk

import "fmt"

// CopticDate is a calendar date on the Coptic (Anno Martyrum) calendar.
type CopticDate struct {
	Year, Month, Day int
}

// isCopticLeap reports whether the given Coptic year is a leap year
// (Julian-style rule: Y mod 4 == 3).
func isCopticLeap(y int) bool { return y%4 == 3 }

// NewCopticDate validates the inputs and returns a CopticDate.
// On invalid input it returns the zero value and a *InvalidCopticDateError.
func NewCopticDate(year, month, day int) (CopticDate, error) {
	if month < 1 || month > 13 {
		return CopticDate{}, &InvalidCopticDateError{
			Year: year, Month: month, Day: day,
			Reason: fmt.Sprintf("coptic month must be 1..13, got %d", month),
		}
	}
	maxDay := 30
	if month == 13 {
		maxDay = 5
		if isCopticLeap(year) {
			maxDay = 6
		}
	}
	if day < 1 || day > maxDay {
		return CopticDate{}, &InvalidCopticDateError{
			Year: year, Month: month, Day: day,
			Reason: fmt.Sprintf("coptic day must be 1..%d for year %d month %d", maxDay, year, month),
		}
	}
	return CopticDate{Year: year, Month: month, Day: day}, nil
}

// ToGregorian converts this Coptic date to a Gregorian date.
// The constructor cannot reject the produced gregorian date; the error is discarded.
func (c CopticDate) ToGregorian() GregorianDate {
	y, m, d := CopticToGregorian(c.Year, c.Month, c.Day)
	g, _ := NewGregorianDate(y, m, d)
	return g
}
