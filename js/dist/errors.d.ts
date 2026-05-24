export declare class InvalidCopticDateException extends Error {
    constructor(year: number, month: number, day: number);
}
export declare class InvalidGregorianDateException extends Error {
    constructor(year: number, month: number, day: number);
}
export declare class UnsupportedLocaleException extends Error {
    constructor(locale: string);
}
