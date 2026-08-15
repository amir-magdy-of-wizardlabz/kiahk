import { GregorianDate } from './GregorianDate.js';
import { Feast } from './Feast.js';
export declare class CopticCalendar {
    private constructor();
    static monthName(month: number, locale: string): string;
    static easterDate(gregorianYear: number): GregorianDate;
    static moveableFeast(feastId: string, gregorianYear: number): Feast;
    /**
     * Coptic day a fixed feast is kept on in `copticYear`. The Nativity is
     * observed on 28 Koiak when the Coptic year is a multiple of 4 — the year
     * after a 6-day Nasie — so it stays on 7 January. See core/algorithms.md §3a.
     */
    private static observedCopticDay;
    static fixedFeasts(gregorianYear: number): Feast[];
    static yearFeasts(gregorianYear: number): Feast[];
}
