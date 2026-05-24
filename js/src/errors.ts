export class InvalidCopticDateException extends Error {
  constructor(year: number, month: number, day: number) {
    super(`Invalid Coptic date: ${year}/${month}/${day}`)
    this.name = 'InvalidCopticDateException'
  }
}

export class InvalidGregorianDateException extends Error {
  constructor(year: number, month: number, day: number) {
    super(`Invalid Gregorian date: ${year}/${month}/${day}`)
    this.name = 'InvalidGregorianDateException'
  }
}

export class UnsupportedLocaleException extends Error {
  constructor(locale: string) {
    super(`Unsupported locale: ${locale}`)
    this.name = 'UnsupportedLocaleException'
  }
}

export class InvalidCopticMonthException extends Error {
  constructor(month: number) {
    super(`Invalid Coptic month: ${month} (expected 1..13)`)
    this.name = 'InvalidCopticMonthException'
  }
}
