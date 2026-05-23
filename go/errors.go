package kiahk

import (
	"errors"
	"fmt"
)

// Sentinel errors. Use errors.Is(err, ErrInvalidCopticDate) to test for
// kind without caring about details.
var (
	ErrInvalidCopticDate    = errors.New("kiahk: invalid coptic date")
	ErrInvalidGregorianDate = errors.New("kiahk: invalid gregorian date")
	ErrUnsupportedLocale    = errors.New("kiahk: unsupported locale")
)

// InvalidCopticDateError wraps ErrInvalidCopticDate with the offending value.
type InvalidCopticDateError struct {
	Year, Month, Day int
	Reason           string
}

func (e *InvalidCopticDateError) Error() string {
	return fmt.Sprintf("kiahk: invalid coptic date %d/%d/%d: %s", e.Year, e.Month, e.Day, e.Reason)
}
func (e *InvalidCopticDateError) Unwrap() error { return ErrInvalidCopticDate }

// InvalidGregorianDateError wraps ErrInvalidGregorianDate with the offending value.
type InvalidGregorianDateError struct {
	Year, Month, Day int
	Reason           string
}

func (e *InvalidGregorianDateError) Error() string {
	return fmt.Sprintf("kiahk: invalid gregorian date %d-%02d-%02d: %s", e.Year, e.Month, e.Day, e.Reason)
}
func (e *InvalidGregorianDateError) Unwrap() error { return ErrInvalidGregorianDate }

// UnsupportedLocaleError wraps ErrUnsupportedLocale with the requested locale.
type UnsupportedLocaleError struct {
	FeastID string
	Locale  string
}

func (e *UnsupportedLocaleError) Error() string {
	return fmt.Sprintf("kiahk: feast %q has no name for locale %q", e.FeastID, e.Locale)
}
func (e *UnsupportedLocaleError) Unwrap() error { return ErrUnsupportedLocale }
