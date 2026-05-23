import { describe, it, expect } from 'vitest'
import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import {
  CopticDate, GregorianDate, CopticCalendar,
  InvalidCopticDateException, InvalidGregorianDateException, UnsupportedLocaleException
} from '../src/index.js'

const __dirname = dirname(fileURLToPath(import.meta.url))

const vectors = JSON.parse(
  readFileSync(resolve(__dirname, '../../core/test-vectors.json'), 'utf8')
)

describe('Gregorian → Coptic', () => {
  it.each(vectors.gregorian_to_coptic)('converts $gregorian to $coptic', ({ gregorian, coptic }: any) => {
    const g = new GregorianDate(gregorian.year, gregorian.month, gregorian.day)
    const c = g.toCoptic()
    expect(c.year).toBe(coptic.year)
    expect(c.month).toBe(coptic.month)
    expect(c.day).toBe(coptic.day)
  })
})

describe('Coptic → Gregorian', () => {
  it.each(vectors.coptic_to_gregorian)('converts $coptic to $gregorian', ({ coptic, gregorian }: any) => {
    const c = new CopticDate(coptic.year, coptic.month, coptic.day)
    const g = c.toGregorian()
    expect(g.year).toBe(gregorian.year)
    expect(g.month).toBe(gregorian.month)
    expect(g.day).toBe(gregorian.day)
  })
})

describe('Easter', () => {
  it.each(vectors.easter)('easter $gregorian_year', ({ gregorian_year, date }: any) => {
    const easter = CopticCalendar.easterDate(gregorian_year)
    expect(easter.year).toBe(date.year)
    expect(easter.month).toBe(date.month)
    expect(easter.day).toBe(date.day)
  })
})

describe('Moveable feasts', () => {
  it.each(vectors.moveable_feasts)('$feast_id in $gregorian_year', ({ gregorian_year, feast_id, date }: any) => {
    const feast = CopticCalendar.moveableFeast(feast_id, gregorian_year)
    expect(feast.gregorianDate.year).toBe(date.year)
    expect(feast.gregorianDate.month).toBe(date.month)
    expect(feast.gregorianDate.day).toBe(date.day)
  })
})

describe('Feast.name()', () => {
  it('returns English name', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(feast.name('en')).toBe('Easter Sunday')
  })
  it('returns Arabic name', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(feast.name('ar')).toBe('عيد القيامة المجيد')
  })
  it('throws UnsupportedLocaleException for unknown locale', () => {
    const feast = CopticCalendar.moveableFeast('easter', 2025)
    expect(() => feast.name('fr')).toThrow(UnsupportedLocaleException)
  })
})

describe('Invalid dates', () => {
  it.each(vectors.invalid_coptic_dates)('throws for invalid coptic $month/$day', ({ year, month, day }: any) => {
    expect(() => new CopticDate(year, month, day)).toThrow(InvalidCopticDateException)
  })
  it.each(vectors.invalid_gregorian_dates)('throws for invalid gregorian $month/$day', ({ year, month, day }: any) => {
    expect(() => new GregorianDate(year, month, day)).toThrow(InvalidGregorianDateException)
  })
})

describe('GregorianDate.toNativeDate()', () => {
  it('returns a JS Date', () => {
    const g = new GregorianDate(2025, 1, 11)
    const d = g.toNativeDate()
    expect(d).toBeInstanceOf(Date)
    expect(d.getFullYear()).toBe(2025)
    expect(d.getMonth()).toBe(0) // 0-indexed
    expect(d.getDate()).toBe(11)
  })
})

describe('GregorianDate.fromNativeDate()', () => {
  it('round-trips a JS Date', () => {
    const native = new Date(2025, 0, 11)
    const g = GregorianDate.fromNativeDate(native)
    expect(g.year).toBe(2025)
    expect(g.month).toBe(1)
    expect(g.day).toBe(11)
  })
})

describe('yearFeasts', () => {
  it('returns feasts sorted by date', () => {
    const feasts = CopticCalendar.yearFeasts(2025)
    expect(feasts.length).toBeGreaterThan(0)
    for (let i = 1; i < feasts.length; i++) {
      const a = feasts[i - 1].gregorianDate
      const b = feasts[i].gregorianDate
      const aMs = new Date(a.year, a.month - 1, a.day).getTime()
      const bMs = new Date(b.year, b.month - 1, b.day).getTime()
      expect(aMs).toBeLessThanOrEqual(bMs)
    }
  })
})
