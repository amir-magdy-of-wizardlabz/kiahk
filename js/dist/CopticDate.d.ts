import { GregorianDate } from './GregorianDate.js';
export declare class CopticDate {
    readonly year: number;
    readonly month: number;
    readonly day: number;
    constructor(year: number, month: number, day: number);
    toGregorian(): GregorianDate;
    toString(): string;
}
