import { copticToGregorian } from './algorithms.js';
import { InvalidCopticDateException } from './errors.js';
import { GregorianDate } from './GregorianDate.js';
function daysInCopticMonth(month, year) {
    if (month >= 1 && month <= 12)
        return 30;
    if (month === 13)
        return year % 4 === 3 ? 6 : 5;
    return 0;
}
export class CopticDate {
    constructor(year, month, day) {
        const maxDay = daysInCopticMonth(month, year);
        if (month < 1 || month > 13 || day < 1 || day > maxDay) {
            throw new InvalidCopticDateException(year, month, day);
        }
        this.year = year;
        this.month = month;
        this.day = day;
    }
    toGregorian() {
        const [y, m, d] = copticToGregorian(this.year, this.month, this.day);
        return new GregorianDate(y, m, d);
    }
    toString() {
        return `${this.year}/${String(this.month).padStart(2, '0')}/${String(this.day).padStart(2, '0')}`;
    }
}
