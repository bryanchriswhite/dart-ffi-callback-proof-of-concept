cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(example VERSION 1.0.0 LANGUAGES C)
add_executable(example async_test.c)

set_target_properties(example PROPERTIES
    PUBLIC_HEADER async.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "async_test"
)
