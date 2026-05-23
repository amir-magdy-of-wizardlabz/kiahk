package kiahk

// Feast is a calendar-resolved feast: a FeastRecord paired with the
// Gregorian date on which it falls for a particular year.
type Feast struct {
	ID            string
	Type          string            // "fixed" | "moveable"
	Category      string            // "major" | "minor"
	Names         map[string]string // locale → localized name
	GregorianDate GregorianDate
}

// Name returns the feast's localized name for the given locale.
// Supported locales: "en", "ar". Unknown locales return *UnsupportedLocaleError.
func (f Feast) Name(locale string) (string, error) {
	if name, ok := f.Names[locale]; ok {
		return name, nil
	}
	return "", &UnsupportedLocaleError{FeastID: f.ID, Locale: locale}
}
