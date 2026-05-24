/**
 * Hand-maintained mirror of core/coptic_months.json. Keep order identical
 * (months 1..13) for cross-port test parity. Inlined (not read from disk)
 * so this module works in both Node and browser environments.
 */
export interface CopticMonthRecord {
    month: number;
    names: Record<string, string>;
}
export declare const COPTIC_MONTHS: CopticMonthRecord[];
