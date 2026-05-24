import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
const __dirname = dirname(fileURLToPath(import.meta.url));
const feastsPath = resolve(__dirname, '../../core/feasts.json');
export const FEASTS = JSON.parse(readFileSync(feastsPath, 'utf8'));
