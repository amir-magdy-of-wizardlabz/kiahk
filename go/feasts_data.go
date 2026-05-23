package kiahk

import "fmt"

// FeastRecord is the static metadata for a feast (mirror of one entry in core/feasts.json).
type FeastRecord struct {
	ID           string
	Names        map[string]string // locale → localized name
	Type         string            // "fixed" | "moveable"
	Category     string            // "major" | "minor"
	CopticMonth  int               // valid when Type == "fixed"
	CopticDay    int               // valid when Type == "fixed"
	EasterOffset int               // valid when Type == "moveable"
}

// Feasts is the hand-maintained mirror of core/feasts.json. Keep order
// identical to the JSON for test parity.
var Feasts = []FeastRecord{
	{ID: "nativity", Names: map[string]string{"en": "Nativity of Christ", "ar": "عيد الميلاد المجيد"}, Type: "fixed", Category: "major", CopticMonth: 4, CopticDay: 29},
	{ID: "epiphany", Names: map[string]string{"en": "Epiphany (Theophany)", "ar": "عيد الغطاس"}, Type: "fixed", Category: "major", CopticMonth: 5, CopticDay: 11},
	{ID: "annunciation", Names: map[string]string{"en": "Annunciation", "ar": "عيد البشارة"}, Type: "fixed", Category: "major", CopticMonth: 7, CopticDay: 29},
	{ID: "assumption", Names: map[string]string{"en": "Assumption of Mary", "ar": "عيد انتقال العذراء"}, Type: "fixed", Category: "major", CopticMonth: 12, CopticDay: 16},
	{ID: "cross", Names: map[string]string{"en": "Feast of the Cross", "ar": "عيد الصليب"}, Type: "fixed", Category: "major", CopticMonth: 1, CopticDay: 17},
	{ID: "nineveh_fast", Names: map[string]string{"en": "Nineveh Fast", "ar": "صوم نينوى"}, Type: "moveable", Category: "major", EasterOffset: -69},
	{ID: "great_lent", Names: map[string]string{"en": "Great Lent (start)", "ar": "بداية الصوم الكبير"}, Type: "moveable", Category: "major", EasterOffset: -55},
	{ID: "palm_sunday", Names: map[string]string{"en": "Palm Sunday", "ar": "أحد الشعانين"}, Type: "moveable", Category: "major", EasterOffset: -7},
	{ID: "easter", Names: map[string]string{"en": "Easter Sunday", "ar": "عيد القيامة المجيد"}, Type: "moveable", Category: "major", EasterOffset: 0},
	{ID: "ascension", Names: map[string]string{"en": "Ascension", "ar": "عيد الصعود"}, Type: "moveable", Category: "major", EasterOffset: 39},
	{ID: "pentecost", Names: map[string]string{"en": "Pentecost", "ar": "عيد العنصرة"}, Type: "moveable", Category: "major", EasterOffset: 49},
}

// FeastByID returns the FeastRecord with the given ID, or an error if none exists.
func FeastByID(id string) (FeastRecord, error) {
	for _, f := range Feasts {
		if f.ID == id {
			return f, nil
		}
	}
	return FeastRecord{}, fmt.Errorf("kiahk: unknown feast id %q", id)
}
