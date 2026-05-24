export class InvalidCopticDateException extends Error {
    constructor(year, month, day) {
        super(`Invalid Coptic date: ${year}/${month}/${day}`);
        this.name = 'InvalidCopticDateException';
    }
}
export class InvalidGregorianDateException extends Error {
    constructor(year, month, day) {
        super(`Invalid Gregorian date: ${year}/${month}/${day}`);
        this.name = 'InvalidGregorianDateException';
    }
}
export class UnsupportedLocaleException extends Error {
    constructor(locale) {
        super(`Unsupported locale: ${locale}`);
        this.name = 'UnsupportedLocaleException';
    }
}
