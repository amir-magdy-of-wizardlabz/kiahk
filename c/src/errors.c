#include "kiahk.h"

const char *kiahk_error_message(kiahk_error err) {
    switch (err) {
        case KIAHK_OK: return "ok";
        case KIAHK_ERR_INVALID_COPTIC_DATE: return "invalid coptic date";
        case KIAHK_ERR_INVALID_GREGORIAN_DATE: return "invalid gregorian date";
        case KIAHK_ERR_UNSUPPORTED_LOCALE: return "unsupported locale";
        case KIAHK_ERR_UNKNOWN_FEAST: return "unknown feast id";
        case KIAHK_ERR_NOT_MOVEABLE: return "feast is not moveable";
        case KIAHK_ERR_BUFFER_TOO_SMALL: return "output buffer too small";
        default: return "unknown error";
    }
}
