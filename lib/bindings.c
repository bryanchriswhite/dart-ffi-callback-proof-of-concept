//
// Created by bwhite on 31.08.21.
//

#include <stdio.h>
#include <stdint.h>

#include "bindings.h"
#include "lib/include/dart_api_dl.h"

void main() {
}

DART_EXPORT intptr_t InitDartApiDL(void* data) {
  return Dart_InitializeApiDL(data);
}

void test_binding_func(int32_t value) {
    printf("%d\n", value);
}