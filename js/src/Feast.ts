import { UnsupportedLocaleException } from './errors.js'
import type { GregorianDate } from './GregorianDate.js'
import type { CopticDate } from './CopticDate.js'

export type FeastType = 'moveable' | 'fixed'
export type FeastCategory = 'major' | 'minor'

export interface FeastData {
  id: string
  names: Record<string, string>
  type: FeastType
  category: FeastCategory
  easter_offset?: number
  coptic_month?: number
  coptic_day?: number
}

export class Feast {
  readonly id: string
  readonly type: FeastType
  readonly category: FeastCategory
  readonly easterOffset: number | null
  readonly gregorianDate: GregorianDate
  readonly copticDate: CopticDate
  private readonly _names: Record<string, string>

  constructor(
    data: FeastData,
    gregorianDate: GregorianDate,
    copticDate: CopticDate
  ) {
    this.id = data.id
    this.type = data.type
    this.category = data.category
    this.easterOffset = data.easter_offset ?? null
    this.gregorianDate = gregorianDate
    this.copticDate = copticDate
    this._names = data.names
  }

  name(locale: string): string {
    if (!(locale in this._names)) throw new UnsupportedLocaleException(locale)
    return this._names[locale]
  }
}
