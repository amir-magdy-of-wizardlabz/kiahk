import type { GregorianDate } from './GregorianDate.js';
import type { CopticDate } from './CopticDate.js';
export type FeastType = 'moveable' | 'fixed';
export type FeastCategory = 'major' | 'minor';
export interface FeastData {
    id: string;
    names: Record<string, string>;
    type: FeastType;
    category: FeastCategory;
    easter_offset?: number;
    coptic_month?: number;
    coptic_day?: number;
}
export declare class Feast {
    readonly id: string;
    readonly type: FeastType;
    readonly category: FeastCategory;
    readonly easterOffset: number | null;
    readonly gregorianDate: GregorianDate;
    readonly copticDate: CopticDate;
    private readonly _names;
    constructor(data: FeastData, gregorianDate: GregorianDate, copticDate: CopticDate);
    name(locale: string): string;
}
