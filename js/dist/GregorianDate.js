import { gregorianToCoptic } from './algorithms.js';
import { InvalidGregorianDateException } from './errors.js';
import { CopticDate } from './CopticDate.js';
const DAYS_IN_MONTH = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
function isLeap(y) { return (y % 4 === 0 && y % 100 !== 0) || y % 400 === 0; }
function daysInGregorianMonth(month, year) {
    if (month === 2 && isLeap(year))
        return 29;
    return DAYS_IN_MONTH[month] ?? 0;
}
export class GregorianDate {
    constructor(year, month, day) {
        const maxDay = daysInGregorianMonth(month, year);
        if (month < 1 || month > 12 || day < 1 || day > maxDay) {
            throw new InvalidGregorianDateException(year, month, day);
        }
        this.year = year;
        this.month = month;
        this.day = day;
    }
    toCoptic() {
        const [y, m, d] = gregorianToCoptic(this.year, this.month, this.day);
        return new CopticDate(y, m, d);
    }
    toNativeDate() {
        return new Date(this.year, this.month - 1, this.day);
    }
    static fromNativeDate(date) {
        return new GregorianDate(date.getFullYear(), date.getMonth() + 1, date.getDate());
    }
    toString() {
        return `${this.year}-${String(this.month).padStart(2, '0')}-${String(this.day).padStart(2, '0')}`;
    }
}
