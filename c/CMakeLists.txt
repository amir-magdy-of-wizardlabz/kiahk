cmake_minimum_required(VERSION 3.16)
project(kiahk
    VERSION 0.1.0
    DESCRIPTION "Coptic calendar arithmetic — date conversion, Easter, and feast days."
    LANGUAGES C
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# Library
add_library(kiahk STATIC
    src/algorithms.c
    src/errors.c
    src/gregorian_date.c
    src/coptic_date.c
    src/feasts_data.c
    src/feast.c
    src/coptic_calendar.c
)
target_include_directories(kiahk PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)
target_compile_options(kiahk PRIVATE
    -Wall -Wextra -Wpedantic -Werror
)

# Tests
enable_testing()
add_executable(test_kiahk
    tests/test_kiahk.c
    tests/vendor/cJSON.c
)
target_link_libraries(test_kiahk PRIVATE kiahk)
target_include_directories(test_kiahk PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/tests
    ${CMAKE_CURRENT_SOURCE_DIR}/tests/vendor
)
target_compile_definitions(test_kiahk PRIVATE
    KIAHK_CORE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../core"
)
target_compile_options(test_kiahk PRIVATE
    -Wall -Wextra
)

add_test(NAME kiahk_tests COMMAND test_kiahk)
