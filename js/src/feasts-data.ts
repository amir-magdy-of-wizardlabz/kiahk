import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import type { FeastData } from './Feast.js'

const __dirname = dirname(fileURLToPath(import.meta.url))
const feastsPath = resolve(__dirname, '../../core/feasts.json')
export const FEASTS: FeastData[] = JSON.parse(readFileSync(feastsPath, 'utf8'))
