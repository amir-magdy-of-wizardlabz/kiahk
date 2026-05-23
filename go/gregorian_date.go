package kiahk

import (
	"fmt"
	"time"
)

// GregorianDate is a calendar date on the proleptic Gregorian calendar.
type GregorianDate struct {
	Year, Month, Day int
}

var gregDaysInMonth = [12]int{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

func isGregLeap(y int) bool { return y%4 == 0 && (y%100 != 0 || y%400 == 0) }

// NewGregorianDate validates the inputs and returns a GregorianDate.
// On invalid input it returns the zero value and a *InvalidGregorianDateError.
func NewGregorianDate(year, month, day int) (GregorianDate, error) {
	if month < 1 || month > 12 {
		return GregorianDate{}, &InvalidGregorianDateError{
			Year: year, Month: month, Day: day,
			Reason: fmt.Sprintf("month must be 1..12, got %d", month),
		}
	}
	maxDay := gregDaysInMonth[month-1]
	if month == 2 && isGregLeap(year) {
		maxDay = 29
	}
	if day < 1 || day > maxDay {
		return GregorianDate{}, &InvalidGregorianDateError{
			Year: year, Month: month, Day: day,
			Reason: fmt.Sprintf("day must be 1..%d for %d-%02d", maxDay, year, month),
		}
	}
	return GregorianDate{Year: year, Month: month, Day: day}, nil
}

// ToCoptic converts this Gregorian date to a Coptic date.
// The constructor cannot reject the produced coptic date because the
// algorithm only ever produces in-range values; the error is discarded.
func (g GregorianDate) ToCoptic() CopticDate {
	y, m, d := GregorianToCoptic(g.Year, g.Month, g.Day)
	c, _ := NewCopticDate(y, m, d)
	return c
}

// ToTime returns a time.Time at 00:00:00 UTC on this date.
func (g GregorianDate) ToTime() time.Time {
	return time.Date(g.Year, time.Month(g.Month), g.Day, 0, 0, 0, 0, time.UTC)
}

// GregorianDateFromTime constructs a GregorianDate from a time.Time.
// Only the calendar date (in the time's own location) is used.
func GregorianDateFromTime(t time.Time) GregorianDate {
	y, m, d := t.Date()
	return GregorianDate{Year: y, Month: int(m), Day: d}
}
