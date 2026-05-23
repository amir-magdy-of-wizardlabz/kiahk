import { computeEaster, addDays } from './algorithms.js'
import { GregorianDate } from './GregorianDate.js'
import { CopticDate } from './CopticDate.js'
import { Feast } from './Feast.js'
import { FEASTS } from './feasts-data.js'

export class CopticCalendar {
  private constructor() {}

  static easterDate(gregorianYear: number): GregorianDate {
    const [y, m, d] = computeEaster(gregorianYear)
    return new GregorianDate(y, m, d)
  }

  static moveableFeast(feastId: string, gregorianYear: number): Feast {
    const data = FEASTS.find(f => f.id === feastId && f.type === 'moveable')
    if (!data) throw new Error(`Unknown moveable feast: ${feastId}`)
    const easter = this.easterDate(gregorianYear)
    const [y, m, d] = addDays(easter.year, easter.month, easter.day, data.easter_offset!)
    const gDate = new GregorianDate(y, m, d)
    return new Feast(data, gDate, gDate.toCoptic())
  }

  static fixedFeasts(gregorianYear: number): Feast[] {
    // A Gregorian year spans two Coptic years — check both
    const cYearStart = new GregorianDate(gregorianYear, 1, 1).toCoptic().year
    const result: Feast[] = []
    const seen = new Set<string>()
    for (const copticYear of [cYearStart, cYearStart + 1]) {
      for (const data of FEASTS.filter(f => f.type === 'fixed')) {
        try {
          const c = new CopticDate(copticYear, data.coptic_month!, data.coptic_day!)
          const g = c.toGregorian()
          if (g.year === gregorianYear && !seen.has(data.id)) {
            seen.add(data.id)
            result.push(new Feast(data, g, c))
          }
        } catch { /* invalid date for this coptic year, skip */ }
      }
    }
    return result
  }

  static yearFeasts(gregorianYear: number): Feast[] {
    const moveable = FEASTS
      .filter(f => f.type === 'moveable')
      .map(data => this.moveableFeast(data.id, gregorianYear))
    const fixed = this.fixedFeasts(gregorianYear)
    return [...fixed, ...moveable].sort((a, b) => {
      const ag = a.gregorianDate, bg = b.gregorianDate
      return new Date(ag.year, ag.month - 1, ag.day).getTime()
           - new Date(bg.year, bg.month - 1, bg.day).getTime()
    })
  }
}
