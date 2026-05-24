#include "kiahk.h"
#include <string.h>

const kiahk_feast_record KIAHK_FEASTS[] = {
    { "nativity",
      { "Nativity of Christ", "عيد الميلاد المجيد" },
      "fixed", "major", 4, 29, 0 },
    { "epiphany",
      { "Epiphany (Theophany)", "عيد الغطاس" },
      "fixed", "major", 5, 11, 0 },
    { "annunciation",
      { "Annunciation", "عيد البشارة" },
      "fixed", "major", 7, 29, 0 },
    { "assumption",
      { "Assumption of Mary", "عيد انتقال العذراء" },
      "fixed", "major", 12, 16, 0 },
    { "cross",
      { "Feast of the Cross", "عيد الصليب" },
      "fixed", "major", 1, 17, 0 },
    { "nineveh_fast",
      { "Nineveh Fast", "صوم نينوى" },
      "moveable", "major", 0, 0, -69 },
    { "great_lent",
      { "Great Lent (start)", "بداية الصوم الكبير" },
      "moveable", "major", 0, 0, -55 },
    { "palm_sunday",
      { "Palm Sunday", "أحد الشعانين" },
      "moveable", "major", 0, 0, -7 },
    { "easter",
      { "Easter Sunday", "عيد القيامة المجيد" },
      "moveable", "major", 0, 0, 0 },
    { "ascension",
      { "Ascension", "عيد الصعود" },
      "moveable", "major", 0, 0, 39 },
    { "pentecost",
      { "Pentecost", "عيد العنصرة" },
      "moveable", "major", 0, 0, 49 }
};

const size_t KIAHK_FEASTS_COUNT = sizeof(KIAHK_FEASTS) / sizeof(KIAHK_FEASTS[0]);

kiahk_error kiahk_feast_by_id(const char *id, const kiahk_feast_record **out) {
    if (!id || !out) return KIAHK_ERR_UNKNOWN_FEAST;
    for (size_t i = 0; i < KIAHK_FEASTS_COUNT; i++) {
        if (strcmp(KIAHK_FEASTS[i].id, id) == 0) {
            *out = &KIAHK_FEASTS[i];
            return KIAHK_OK;
        }
    }
    *out = NULL;
    return KIAHK_ERR_UNKNOWN_FEAST;
}
