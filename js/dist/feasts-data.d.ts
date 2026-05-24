import type { FeastData } from './Feast.js';
/**
 * Hand-maintained mirror of core/feasts.json. Keep order identical for
 * cross-port test parity. Inlined (not read from disk) so this module works
 * in both Node and browser environments.
 */
export declare const FEASTS: FeastData[];
