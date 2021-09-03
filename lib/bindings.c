//
// Created by bwhite on 31.08.21.
//

#include <stdio.h>
#include <stdint.h>

#include "bindings.h"
#include "include/dart_api.h"
#include "include/dart_api_dl.h"

int64_t main_send_port;

void main() {
}

intptr_t init_dart_api_dl(void* data) {
  return Dart_InitializeApiDL(data);
}

void async_example(int32_t value, intptr_t send_port) {
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt32;
    dart_object.value.as_int32 = value;

    auto result = Dart_PostCObject_DL(send_port, &dart_object);
}