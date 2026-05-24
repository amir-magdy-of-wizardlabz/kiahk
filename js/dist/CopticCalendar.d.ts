import { GregorianDate } from './GregorianDate.js';
import { Feast } from './Feast.js';
export declare class CopticCalendar {
    private constructor();
    static monthName(month: number, locale: string): string;
    static easterDate(gregorianYear: number): GregorianDate;
    static moveableFeast(feastId: string, gregorianYear: number): Feast;
    static fixedFeasts(gregorianYear: number): Feast[];
    static yearFeasts(gregorianYear: number): Feast[];
}
