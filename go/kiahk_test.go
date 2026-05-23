package kiahk_test

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"
	"time"

	kiahk "github.com/amir-magdy-of-wizardlabz/kiahk/go"
)

// ----------------------------------------------------------------------
// Shared test-vector loader (parsed once at package init time).
// ----------------------------------------------------------------------

type gregCoptic struct {
	Gregorian struct{ Year, Month, Day int } `json:"gregorian"`
	Coptic    struct{ Year, Month, Day int } `json:"coptic"`
}

type easterVec struct {
	GregorianYear int                            `json:"gregorian_year"`
	Date          struct{ Year, Month, Day int } `json:"date"`
}

type moveableVec struct {
	GregorianYear int                            `json:"gregorian_year"`
	FeastID       string                         `json:"feast_id"`
	Date          struct{ Year, Month, Day int } `json:"date"`
}

type invalidDate struct {
	Year, Month, Day int
}

type vectors struct {
	GregorianToCoptic     []gregCoptic  `json:"gregorian_to_coptic"`
	CopticToGregorian     []gregCoptic  `json:"coptic_to_gregorian"`
	Easter                []easterVec   `json:"easter"`
	MoveableFeasts        []moveableVec `json:"moveable_feasts"`
	InvalidCopticDates    []invalidDate `json:"invalid_coptic_dates"`
	InvalidGregorianDates []invalidDate `json:"invalid_gregorian_dates"`
}

var v vectors

func init() {
	data, err := os.ReadFile(filepath.Join("..", "core", "test-vectors.json"))
	if err != nil {
		panic("kiahk_test: cannot read core/test-vectors.json: " + err.Error())
	}
	if err := json.Unmarshal(data, &v); err != nil {
		panic("kiahk_test: cannot parse core/test-vectors.json: " + err.Error())
	}
}

// ----------------------------------------------------------------------
// Error sentinels + typed errors
// ----------------------------------------------------------------------

func TestErrorSentinelsExist(t *testing.T) {
	t.Helper()
	for name, sentinel := range map[string]error{
		"ErrInvalidCopticDate":    kiahk.ErrInvalidCopticDate,
		"ErrInvalidGregorianDate": kiahk.ErrInvalidGregorianDate,
		"ErrUnsupportedLocale":    kiahk.ErrUnsupportedLocale,
	} {
		if sentinel == nil {
			t.Errorf("expected sentinel %s to be non-nil", name)
		}
	}
}

func TestInvalidCopticDateErrorImplementsErrorAndIs(t *testing.T) {
	err := &kiahk.InvalidCopticDateError{Year: 1741, Month: 14, Day: 1, Reason: "month out of range"}
	var asErr error = err
	if asErr == nil {
		t.Fatal("*InvalidCopticDateError must implement error")
	}
	if !errors.Is(err, kiahk.ErrInvalidCopticDate) {
		t.Fatal("errors.Is(InvalidCopticDateError, ErrInvalidCopticDate) must be true")
	}
}

func TestInvalidGregorianDateErrorImplementsErrorAndIs(t *testing.T) {
	err := &kiahk.InvalidGregorianDateError{Year: 2025, Month: 2, Day: 29, Reason: "not a leap year"}
	if !errors.Is(err, kiahk.ErrInvalidGregorianDate) {
		t.Fatal("errors.Is(InvalidGregorianDateError, ErrInvalidGregorianDate) must be true")
	}
}

func TestUnsupportedLocaleErrorImplementsErrorAndIs(t *testing.T) {
	err := &kiahk.UnsupportedLocaleError{FeastID: "easter", Locale: "fr"}
	if !errors.Is(err, kiahk.ErrUnsupportedLocale) {
		t.Fatal("errors.Is(UnsupportedLocaleError, ErrUnsupportedLocale) must be true")
	}
}

// ----------------------------------------------------------------------
// algorithms: GregorianToJdn
// ----------------------------------------------------------------------

func TestGregorianToJdnKnownValues(t *testing.T) {
	cases := []struct {
		y, m, d int
		jdn     int
	}{
		{2000, 1, 1, 2451545},
		{1900, 1, 1, 2415021},
		{2025, 1, 11, 2460687},
	}
	for _, c := range cases {
		got := kiahk.GregorianToJdn(c.y, c.m, c.d)
		if got != c.jdn {
			t.Errorf("GregorianToJdn(%d, %d, %d) = %d, want %d", c.y, c.m, c.d, got, c.jdn)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: JdnToGregorian + round trip
// ----------------------------------------------------------------------

func TestJdnRoundTrip(t *testing.T) {
	cases := [][3]int{{2000, 1, 1}, {1900, 1, 1}, {2025, 1, 11}, {2024, 12, 25}, {2025, 9, 11}}
	for _, c := range cases {
		jdn := kiahk.GregorianToJdn(c[0], c[1], c[2])
		y, m, d := kiahk.JdnToGregorian(jdn)
		if y != c[0] || m != c[1] || d != c[2] {
			t.Errorf("round trip %d-%d-%d → JDN %d → %d-%d-%d", c[0], c[1], c[2], jdn, y, m, d)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: CopticToJdn (epoch is JDN 1825030)
// ----------------------------------------------------------------------

func TestCopticToJdnEpoch(t *testing.T) {
	if got := kiahk.CopticToJdn(1, 1, 1); got != 1825030 {
		t.Errorf("CopticToJdn(1, 1, 1) = %d, want 1825030", got)
	}
}

// ----------------------------------------------------------------------
// algorithms: JdnToCoptic + round trip via vectors
// ----------------------------------------------------------------------

func TestCopticJdnRoundTrip(t *testing.T) {
	for _, vec := range v.GregorianToCoptic {
		c := vec.Coptic
		jdn := kiahk.CopticToJdn(c.Year, c.Month, c.Day)
		gy, gm, gd := kiahk.JdnToCoptic(jdn)
		if gy != c.Year || gm != c.Month || gd != c.Day {
			t.Errorf("Coptic %d/%d/%d → JDN %d → %d/%d/%d", c.Year, c.Month, c.Day, jdn, gy, gm, gd)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: GregorianToCoptic (vectors)
// ----------------------------------------------------------------------

func TestGregorianToCopticVectors(t *testing.T) {
	for _, vec := range v.GregorianToCoptic {
		g, c := vec.Gregorian, vec.Coptic
		gy, gm, gd := kiahk.GregorianToCoptic(g.Year, g.Month, g.Day)
		if gy != c.Year || gm != c.Month || gd != c.Day {
			t.Errorf("GregorianToCoptic(%d, %d, %d) = (%d, %d, %d), want (%d, %d, %d)",
				g.Year, g.Month, g.Day, gy, gm, gd, c.Year, c.Month, c.Day)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: CopticToGregorian (vectors)
// ----------------------------------------------------------------------

func TestCopticToGregorianVectors(t *testing.T) {
	for _, vec := range v.CopticToGregorian {
		c, g := vec.Coptic, vec.Gregorian
		gy, gm, gd := kiahk.CopticToGregorian(c.Year, c.Month, c.Day)
		if gy != g.Year || gm != g.Month || gd != g.Day {
			t.Errorf("CopticToGregorian(%d, %d, %d) = (%d, %d, %d), want (%d, %d, %d)",
				c.Year, c.Month, c.Day, gy, gm, gd, g.Year, g.Month, g.Day)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: ComputeEaster (vectors)
// ----------------------------------------------------------------------

func TestComputeEasterVectors(t *testing.T) {
	for _, vec := range v.Easter {
		y, m, d := kiahk.ComputeEaster(vec.GregorianYear)
		want := vec.Date
		if y != want.Year || m != want.Month || d != want.Day {
			t.Errorf("ComputeEaster(%d) = (%d, %d, %d), want (%d, %d, %d)",
				vec.GregorianYear, y, m, d, want.Year, want.Month, want.Day)
		}
	}
}

// ----------------------------------------------------------------------
// algorithms: AddDays
// ----------------------------------------------------------------------

func TestAddDaysKnownOffsets(t *testing.T) {
	cases := []struct {
		y, m, d, n int
		ey, em, ed int
		label      string
	}{
		{2025, 1, 1, 10, 2025, 1, 11, "+10"},
		{2025, 1, 1, -1, 2024, 12, 31, "-1 crosses year"},
		{2024, 2, 28, 1, 2024, 2, 29, "leap year +1"},
	}
	for _, c := range cases {
		y, m, d := kiahk.AddDays(c.y, c.m, c.d, c.n)
		if y != c.ey || m != c.em || d != c.ed {
			t.Errorf("%s: AddDays(%d, %d, %d, %d) = (%d, %d, %d), want (%d, %d, %d)",
				c.label, c.y, c.m, c.d, c.n, y, m, d, c.ey, c.em, c.ed)
		}
	}
}

// ----------------------------------------------------------------------
// GregorianDate
// ----------------------------------------------------------------------

func TestNewGregorianDateBasic(t *testing.T) {
	g, err := kiahk.NewGregorianDate(2025, 1, 11)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if g.Year != 2025 || g.Month != 1 || g.Day != 11 {
		t.Errorf("got %+v", g)
	}
}

func TestNewGregorianDateRejectsInvalid(t *testing.T) {
	for _, bad := range v.InvalidGregorianDates {
		_, err := kiahk.NewGregorianDate(bad.Year, bad.Month, bad.Day)
		if err == nil {
			t.Errorf("NewGregorianDate(%d, %d, %d) returned nil error", bad.Year, bad.Month, bad.Day)
			continue
		}
		if !errors.Is(err, kiahk.ErrInvalidGregorianDate) {
			t.Errorf("expected ErrInvalidGregorianDate sentinel, got %v", err)
		}
	}
}

func TestGregorianDateToTime(t *testing.T) {
	g, _ := kiahk.NewGregorianDate(2025, 1, 11)
	tm := g.ToTime()
	want := time.Date(2025, time.January, 11, 0, 0, 0, 0, time.UTC)
	if !tm.Equal(want) {
		t.Errorf("ToTime() = %v, want %v", tm, want)
	}
}

func TestGregorianDateFromTime(t *testing.T) {
	tm := time.Date(2025, time.January, 11, 12, 34, 56, 0, time.UTC)
	g := kiahk.GregorianDateFromTime(tm)
	if g.Year != 2025 || g.Month != 1 || g.Day != 11 {
		t.Errorf("got %+v", g)
	}
}

// ----------------------------------------------------------------------
// CopticDate
// ----------------------------------------------------------------------

func TestNewCopticDateBasic(t *testing.T) {
	c, err := kiahk.NewCopticDate(1741, 5, 3)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if c.Year != 1741 || c.Month != 5 || c.Day != 3 {
		t.Errorf("got %+v", c)
	}
}

func TestNewCopticDateRejectsInvalid(t *testing.T) {
	for _, bad := range v.InvalidCopticDates {
		_, err := kiahk.NewCopticDate(bad.Year, bad.Month, bad.Day)
		if err == nil {
			t.Errorf("NewCopticDate(%d, %d, %d) returned nil error", bad.Year, bad.Month, bad.Day)
			continue
		}
		if !errors.Is(err, kiahk.ErrInvalidCopticDate) {
			t.Errorf("expected ErrInvalidCopticDate sentinel, got %v", err)
		}
	}
}

func TestCopticDateToGregorian(t *testing.T) {
	c, _ := kiahk.NewCopticDate(1741, 5, 3)
	g := c.ToGregorian()
	if g.Year != 2025 || g.Month != 1 || g.Day != 11 {
		t.Errorf("ToGregorian() = %+v, want 2025-01-11", g)
	}
}

func TestGregorianDateToCopticInstance(t *testing.T) {
	g, _ := kiahk.NewGregorianDate(2025, 1, 11)
	c := g.ToCoptic()
	if c.Year != 1741 || c.Month != 5 || c.Day != 3 {
		t.Errorf("ToCoptic() = %+v, want 1741/5/3", c)
	}
}

// ----------------------------------------------------------------------
// feasts_data parity with core/feasts.json
// ----------------------------------------------------------------------

func TestFeastsDataMatchesCoreFeastsJSON(t *testing.T) {
	data, err := os.ReadFile(filepath.Join("..", "core", "feasts.json"))
	if err != nil {
		t.Fatalf("cannot read core/feasts.json: %v", err)
	}
	var core []map[string]any
	if err := json.Unmarshal(data, &core); err != nil {
		t.Fatalf("cannot parse core/feasts.json: %v", err)
	}
	if len(kiahk.Feasts) != len(core) {
		t.Fatalf("len(Feasts)=%d, want %d", len(kiahk.Feasts), len(core))
	}
	for i, f := range kiahk.Feasts {
		ref := core[i]
		if f.ID != ref["id"].(string) {
			t.Errorf("[%d] id mismatch: got %q want %q", i, f.ID, ref["id"])
		}
		if f.Type != ref["type"].(string) {
			t.Errorf("[%d] type mismatch", i)
		}
		if f.Category != ref["category"].(string) {
			t.Errorf("[%d] category mismatch", i)
		}
		refNames := ref["names"].(map[string]any)
		if f.Names["en"] != refNames["en"].(string) {
			t.Errorf("[%d] en mismatch: got %q want %q", i, f.Names["en"], refNames["en"])
		}
		if f.Names["ar"] != refNames["ar"].(string) {
			t.Errorf("[%d] ar mismatch: got %q want %q", i, f.Names["ar"], refNames["ar"])
		}
	}
}

// ----------------------------------------------------------------------
// Feast
// ----------------------------------------------------------------------

func TestFeastBasicFieldsAndName(t *testing.T) {
	g, _ := kiahk.NewGregorianDate(2025, 4, 20)
	rec, _ := kiahk.FeastByID("easter")
	feast := kiahk.Feast{
		ID: rec.ID, Type: rec.Type, Category: rec.Category,
		Names: rec.Names, GregorianDate: g,
	}
	if feast.ID != "easter" || feast.Type != "moveable" || feast.Category != "major" {
		t.Errorf("got %+v", feast)
	}
	if name, err := feast.Name("en"); err != nil || name != "Easter Sunday" {
		t.Errorf("Name(en) = %q, %v", name, err)
	}
	if name, err := feast.Name("ar"); err != nil || name != "عيد القيامة المجيد" {
		t.Errorf("Name(ar) = %q, %v", name, err)
	}
}

func TestFeastNameUnknownLocale(t *testing.T) {
	g, _ := kiahk.NewGregorianDate(2025, 4, 20)
	rec, _ := kiahk.FeastByID("easter")
	feast := kiahk.Feast{ID: rec.ID, Type: rec.Type, Category: rec.Category, Names: rec.Names, GregorianDate: g}
	_, err := feast.Name("fr")
	if err == nil {
		t.Fatal("expected error for unknown locale")
	}
	if !errors.Is(err, kiahk.ErrUnsupportedLocale) {
		t.Errorf("expected ErrUnsupportedLocale, got %v", err)
	}
}

// ----------------------------------------------------------------------
// EasterDate (package-level)
// ----------------------------------------------------------------------

func TestEasterDateVectors(t *testing.T) {
	for _, vec := range v.Easter {
		got := kiahk.EasterDate(vec.GregorianYear)
		want := vec.Date
		if got.Year != want.Year || got.Month != want.Month || got.Day != want.Day {
			t.Errorf("EasterDate(%d) = %+v, want %d-%d-%d",
				vec.GregorianYear, got, want.Year, want.Month, want.Day)
		}
	}
}

// ----------------------------------------------------------------------
// MoveableFeast
// ----------------------------------------------------------------------

func TestMoveableFeastVectors(t *testing.T) {
	for _, vec := range v.MoveableFeasts {
		feast, err := kiahk.MoveableFeast(vec.FeastID, vec.GregorianYear)
		if err != nil {
			t.Errorf("MoveableFeast(%q, %d) error: %v", vec.FeastID, vec.GregorianYear, err)
			continue
		}
		if feast.ID != vec.FeastID {
			t.Errorf("ID mismatch: got %q want %q", feast.ID, vec.FeastID)
		}
		g := feast.GregorianDate
		if g.Year != vec.Date.Year || g.Month != vec.Date.Month || g.Day != vec.Date.Day {
			t.Errorf("MoveableFeast(%q, %d) date = %+v, want %d-%d-%d",
				vec.FeastID, vec.GregorianYear, g, vec.Date.Year, vec.Date.Month, vec.Date.Day)
		}
	}
}

// ----------------------------------------------------------------------
// YearFeasts (sorted)
// ----------------------------------------------------------------------

func TestYearFeastsNonEmptyAndSorted(t *testing.T) {
	feasts := kiahk.YearFeasts(2025)
	if len(feasts) == 0 {
		t.Fatal("YearFeasts(2025) returned empty slice")
	}
	for i := 1; i < len(feasts); i++ {
		a := feasts[i-1].GregorianDate
		b := feasts[i].GregorianDate
		if !lessOrEqualDate(a, b) {
			t.Errorf("YearFeasts not sorted at %d: %+v > %+v", i, a, b)
		}
	}
}

func TestYearFeastsIncludesEaster(t *testing.T) {
	feasts := kiahk.YearFeasts(2025)
	for _, f := range feasts {
		if f.ID == "easter" {
			g := f.GregorianDate
			if g.Year != 2025 || g.Month != 4 || g.Day != 20 {
				t.Errorf("Easter 2025 = %+v, want 2025-04-20", g)
			}
			return
		}
	}
	t.Fatal("Easter not found in YearFeasts(2025)")
}

func lessOrEqualDate(a, b kiahk.GregorianDate) bool {
	if a.Year != b.Year {
		return a.Year < b.Year
	}
	if a.Month != b.Month {
		return a.Month < b.Month
	}
	return a.Day <= b.Day
}
