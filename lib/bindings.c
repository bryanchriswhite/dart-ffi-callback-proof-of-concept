//
// Created by bwhite on 31.08.21.
//

#include <stdio.h>
#include <stdint.h>

#include "bindings.h"
#include "./include/dart_api_dl.h"

int64_t main_send_port;

void main() {
}

intptr_t init_dart_api_dl(void* data) {
  return Dart_InitializeApiDL(data);
}

void test_binding_func(int32_t value) {
    printf("C | test_binding_func:19 %d\n", value);

    // Dart_CObject dart_object;
    // dart_object.type =

    // // TODO: add `send_port` arg (?)
    // Dart_PostCObject_DL(main_send_port, &dart_object);
}

void register_send_port (int64_t send_port) {
    printf("C | RegisterSendPort:24 %d\n", send_port);
    main_send_port = send_port;
}