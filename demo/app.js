import {
  GregorianDate,
  CopticDate,
  CopticCalendar,
  InvalidGregorianDateException,
} from '../js/dist/index.js';

// Coptic month names, English + Arabic (1-indexed; index 0 unused).
const COPTIC_MONTHS = {
  en: [
    '', 'Thout', 'Paopi', 'Hathor', 'Koiak', 'Tobi',
    'Meshir', 'Paremhat', 'Parmouti', 'Pashons', 'Paoni',
    'Epip', 'Mesori', 'Nasie',
  ],
  ar: [
    '', 'توت', 'بابة', 'هاتور', 'كيهك', 'طوبة',
    'أمشير', 'برمهات', 'برمودة', 'بشنس', 'بؤونة',
    'أبيب', 'مسرى', 'نسيء',
  ],
};

// ----- Date converter -----

const gregInput = document.getElementById('gregInput');
const copticOutput = document.getElementById('copticOutput');

function pad2(n) {
  return String(n).padStart(2, '0');
}

function updateConverter() {
  const value = gregInput.value;
  if (!value) {
    copticOutput.innerHTML = '<span class="hint">Pick a date above.</span>';
    return;
  }
  const [y, m, d] = value.split('-').map(Number);
  try {
    const g = new GregorianDate(y, m, d);
    const c = g.toCoptic();
    const enName = COPTIC_MONTHS.en[c.month] ?? `Month ${c.month}`;
    const arName = COPTIC_MONTHS.ar[c.month] ?? '';
    copticOutput.innerHTML = `
      <div class="result-line">
        <strong>${c.day} ${enName} ${c.year} AM</strong>
      </div>
      <div class="result-line-ar" dir="rtl" lang="ar">
        ${c.day} ${arName} ${c.year} للشهداء
      </div>
      <div class="result-meta">
        Coptic year ${c.year} &middot; month ${c.month} &middot; day ${c.day}
      </div>
    `;
  } catch (err) {
    copticOutput.innerHTML = `<span class="err">${escape(err.message)}</span>`;
  }
}

// ----- Year feasts -----

const yearInput = document.getElementById('yearInput');
const feastsOutput = document.getElementById('feastsOutput');

function updateFeasts() {
  const raw = yearInput.value;
  const year = parseInt(raw, 10);
  if (!Number.isFinite(year) || year < 1900 || year > 2099) {
    feastsOutput.innerHTML = '<span class="err">Enter a year between 1900 and 2099.</span>';
    return;
  }
  try {
    const feasts = CopticCalendar.yearFeasts(year);
    if (feasts.length === 0) {
      feastsOutput.innerHTML = '<span class="hint">No feasts found.</span>';
      return;
    }
    const rows = feasts.map((f) => {
      const d = f.gregorianDate;
      const date = `${d.year}-${pad2(d.month)}-${pad2(d.day)}`;
      const en = escape(f.name('en'));
      const ar = escape(f.name('ar'));
      const kind = f.type === 'moveable' ? 'moveable' : 'fixed';
      return `
        <tr>
          <td class="date-cell">${date}</td>
          <td>${en}</td>
          <td dir="rtl" lang="ar">${ar}</td>
          <td><span class="badge badge-${kind}">${kind}</span></td>
        </tr>
      `;
    }).join('');
    feastsOutput.innerHTML = `
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Feast (en)</th>
            <th>Feast (ar)</th>
            <th>Kind</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
    `;
  } catch (err) {
    feastsOutput.innerHTML = `<span class="err">${escape(err.message)}</span>`;
  }
}

// ----- Helpers -----

function escape(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// ----- Wire up -----

const today = new Date();
gregInput.value = `${today.getFullYear()}-${pad2(today.getMonth() + 1)}-${pad2(today.getDate())}`;
yearInput.value = today.getFullYear();

updateConverter();
updateFeasts();

gregInput.addEventListener('input', updateConverter);
yearInput.addEventListener('input', updateFeasts);
