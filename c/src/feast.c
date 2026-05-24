#include "kiahk.h"
#include <string.h>

kiahk_error kiahk_feast_name(const kiahk_feast *f, const char *locale, const char **out) {
    if (!f || !locale || !out || !f->names) return KIAHK_ERR_UNSUPPORTED_LOCALE;
    if (strcmp(locale, "en") == 0) {
        *out = f->names->en;
        return KIAHK_OK;
    }
    if (strcmp(locale, "ar") == 0) {
        *out = f->names->ar;
        return KIAHK_OK;
    }
    *out = NULL;
    return KIAHK_ERR_UNSUPPORTED_LOCALE;
}
