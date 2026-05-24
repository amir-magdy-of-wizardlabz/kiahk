import { CopticDate } from './CopticDate.js';
export declare class GregorianDate {
    readonly year: number;
    readonly month: number;
    readonly day: number;
    constructor(year: number, month: number, day: number);
    toCoptic(): CopticDate;
    toNativeDate(): Date;
    static fromNativeDate(date: Date): GregorianDate;
    toString(): string;
}
