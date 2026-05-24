import { UnsupportedLocaleException } from './errors.js';
export class Feast {
    constructor(data, gregorianDate, copticDate) {
        this.id = data.id;
        this.type = data.type;
        this.category = data.category;
        this.easterOffset = data.easter_offset ?? null;
        this.gregorianDate = gregorianDate;
        this.copticDate = copticDate;
        this._names = data.names;
    }
    name(locale) {
        if (!(locale in this._names))
            throw new UnsupportedLocaleException(locale);
        return this._names[locale];
    }
}
