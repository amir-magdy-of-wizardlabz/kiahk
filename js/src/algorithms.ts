/** Gregorian date → Julian Day Number */
export function gregorianToJdn(year: number, month: number, day: number): number {
  const a = Math.floor((14 - month) / 12)
  const y = year + 4800 - a
  const m = month + 12 * a - 3
  return day + Math.floor((153 * m + 2) / 5) + 365 * y +
    Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400) - 32045
}

/** Julian Day Number → Gregorian date */
export function jdnToGregorian(jdn: number): [number, number, number] {
  const a = jdn + 32044
  const b = Math.floor((4 * a + 3) / 146097)
  const c = a - Math.floor((146097 * b) / 4)
  const d = Math.floor((4 * c + 3) / 1461)
  const e = c - Math.floor((1461 * d) / 4)
  const m = Math.floor((5 * e + 2) / 153)
  const day = e - Math.floor((153 * m + 2) / 5) + 1
  const month = m + 3 - 12 * Math.floor(m / 10)
  const year = 100 * b + d - 4800 + Math.floor(m / 10)
  return [year, month, day]
}

const COPTIC_EPOCH = 1825030

/** Gregorian → Coptic via JDN */
export function gregorianToCoptic(gYear: number, gMonth: number, gDay: number): [number, number, number] {
  const jdn = gregorianToJdn(gYear, gMonth, gDay)
  const r = jdn - COPTIC_EPOCH
  const cYear = Math.floor((4 * r + 1463) / 1461) - 1
  const remain = r - 365 * cYear - Math.floor(cYear / 4)
  const cMonth = Math.floor(remain / 30) + 1
  const cDay = remain - 30 * (cMonth - 1) + 1
  return [cYear, Math.min(cMonth, 13), cDay]
}

/** Coptic → Gregorian via JDN */
export function copticToGregorian(cYear: number, cMonth: number, cDay: number): [number, number, number] {
  const jdn = cDay + 30 * (cMonth - 1) + 365 * cYear + Math.floor(cYear / 4) + COPTIC_EPOCH - 1
  return jdnToGregorian(jdn)
}

/** Coptic Easter (Butcher's algorithm + 13-day Gregorian offset) */
export function computeEaster(gregorianYear: number): [number, number, number] {
  const a = gregorianYear % 4
  const b = gregorianYear % 7
  const c = gregorianYear % 19
  const d = (19 * c + 15) % 30
  const e = (2 * a + 4 * b - d + 34) % 7
  const f = Math.floor((d + e + 114) / 31)  // month
  const g = ((d + e + 114) % 31) + 1        // day
  // Julian Easter date, add 13 days for Gregorian
  const jdn = gregorianToJdn(gregorianYear, f, g) + 13
  return jdnToGregorian(jdn)
}

/** Add N days to a Gregorian date, returns new [year, month, day] */
export function addDays(year: number, month: number, day: number, days: number): [number, number, number] {
  const jdn = gregorianToJdn(year, month, day) + days
  return jdnToGregorian(jdn)
}
