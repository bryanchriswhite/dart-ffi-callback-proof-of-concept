cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(bindings VERSION 1.0.0 LANGUAGES C)
add_library(bindings SHARED bindings.c include/dart_api_dl.c)
add_executable(bindings_test bindings.c include/dart_api_dl.c)

set_target_properties(bindings PROPERTIES
    PUBLIC_HEADER bindings.h
    PUBLIC_HEADER include/dart_version.h
    PUBLIC_HEADER include/dart_api.h
    PUBLIC_HEADER include/dart_api_dl.h
    PUBLIC_HEADER include/dart_naitive_dl.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "bindings"
)