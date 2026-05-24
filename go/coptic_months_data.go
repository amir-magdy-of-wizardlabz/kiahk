package kiahk

// CopticMonthRecord is one entry of the Coptic month-name table
// (mirror of one entry in core/coptic_months.json).
type CopticMonthRecord struct {
	Month int               // 1..13
	Names map[string]string // locale → localized name
}

// CopticMonths is the hand-maintained mirror of core/coptic_months.json.
// Keep order identical (months 1..13) for cross-port test parity.
var CopticMonths = []CopticMonthRecord{
	{Month: 1, Names: map[string]string{"en": "Thout", "ar": "توت"}},
	{Month: 2, Names: map[string]string{"en": "Paopi", "ar": "بابة"}},
	{Month: 3, Names: map[string]string{"en": "Hathor", "ar": "هاتور"}},
	{Month: 4, Names: map[string]string{"en": "Koiak", "ar": "كيهك"}},
	{Month: 5, Names: map[string]string{"en": "Tobi", "ar": "طوبة"}},
	{Month: 6, Names: map[string]string{"en": "Meshir", "ar": "أمشير"}},
	{Month: 7, Names: map[string]string{"en": "Paremhat", "ar": "برمهات"}},
	{Month: 8, Names: map[string]string{"en": "Parmouti", "ar": "برمودة"}},
	{Month: 9, Names: map[string]string{"en": "Pashons", "ar": "بشنس"}},
	{Month: 10, Names: map[string]string{"en": "Paoni", "ar": "بؤونة"}},
	{Month: 11, Names: map[string]string{"en": "Epip", "ar": "أبيب"}},
	{Month: 12, Names: map[string]string{"en": "Mesori", "ar": "مسرى"}},
	{Month: 13, Names: map[string]string{"en": "Nasie", "ar": "نسيء"}},
}
