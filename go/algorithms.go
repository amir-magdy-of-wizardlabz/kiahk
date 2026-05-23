package kiahk

// copticEpoch is the Julian Day Number of 1 Tout, year 1 AM
// (11 September 284 CE proleptic Gregorian).
const copticEpoch = 1825030

// GregorianToJdn converts a Gregorian date to a Julian Day Number
// (Fliegel & Van Flandern formula).
func GregorianToJdn(year, month, day int) int {
	a := (14 - month) / 12
	y := year + 4800 - a
	m := month + 12*a - 3
	return day +
		(153*m+2)/5 +
		365*y +
		y/4 -
		y/100 +
		y/400 -
		32045
}

// JdnToGregorian converts a Julian Day Number to a Gregorian date.
func JdnToGregorian(jdn int) (year, month, day int) {
	a := jdn + 32044
	b := (4*a + 3) / 146097
	c := a - (146097*b)/4
	d := (4*c + 3) / 1461
	e := c - (1461*d)/4
	m := (5*e + 2) / 153
	day = e - (153*m+2)/5 + 1
	month = m + 3 - 12*(m/10)
	year = 100*b + d - 4800 + m/10
	return
}

// CopticToJdn converts a Coptic date to a Julian Day Number.
//
// Days before Coptic year cYear (within AM era):
//   365*(cYear-1) full years + one extra day for every Coptic leap year in [1, cYear-1].
// The count of leap years in [1, cYear-1] is floor(cYear/4) because Y is leap iff Y mod 4 == 3.
func CopticToJdn(cYear, cMonth, cDay int) int {
	return copticEpoch - 1 +
		365*(cYear-1) +
		cYear/4 +
		30*(cMonth-1) +
		cDay
}

// JdnToCoptic converts a Julian Day Number to a Coptic date.
//
// Let r = jdn - copticEpoch (0 = 1 Tout 1 AM). Solve
//   r = 365*(cYear-1) + floor(cYear/4) + dayOfYear,  0 <= dayOfYear <= 365.
// Closed form: cYear = floor((4*r + 1463) / 1461).
func JdnToCoptic(jdn int) (year, month, day int) {
	r := jdn - copticEpoch
	year = (4*r + 1463) / 1461
	dayOfYear := r - 365*(year-1) - year/4 // 0-indexed
	month = dayOfYear/30 + 1
	day = dayOfYear - 30*(month-1) + 1
	return
}

// GregorianToCoptic converts a Gregorian date to a Coptic date.
func GregorianToCoptic(gYear, gMonth, gDay int) (cYear, cMonth, cDay int) {
	return JdnToCoptic(GregorianToJdn(gYear, gMonth, gDay))
}

// CopticToGregorian converts a Coptic date to a Gregorian date.
func CopticToGregorian(cYear, cMonth, cDay int) (gYear, gMonth, gDay int) {
	return JdnToGregorian(CopticToJdn(cYear, cMonth, cDay))
}

// ComputeEaster returns Coptic / Orthodox Easter Sunday on the Gregorian calendar.
// (Meeus's Julian computus + 13-day Julian→Gregorian shift; valid 1900-03-01 .. 2100-02-28.)
func ComputeEaster(gregorianYear int) (year, month, day int) {
	a := gregorianYear % 4
	b := gregorianYear % 7
	c := gregorianYear % 19
	d := (19*c + 15) % 30
	e := (2*a + 4*b - d + 34) % 7
	f := (d + e + 114) / 31 // Julian-calendar month
	g := (d+e+114)%31 + 1   // Julian-calendar day
	jdn := GregorianToJdn(gregorianYear, f, g) + 13
	return JdnToGregorian(jdn)
}

// AddDays adds n days to a Gregorian date and returns the new date.
func AddDays(year, month, day, n int) (y, m, d int) {
	return JdnToGregorian(GregorianToJdn(year, month, day) + n)
}
