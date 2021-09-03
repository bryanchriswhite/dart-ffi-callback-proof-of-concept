import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:async_callback_test_integration/definitions.dart';

class NativeAsync implements AsyncInterface {
  late final DynamicLibrary _dl;

  NativeAsync() {
    _dl = dlOpen();
    _initDartApi(NativeApi.initializeApiDLData);
  }

  static DynamicLibrary dlOpen() {
    // TODO: - [ ] using platform-specific paths
    // TODO: - [ ] cleaned up build output paths and add to .gitignore file
    return DynamicLibrary.open('./libbindings.so');
  }

  // Implement `asyncExample` member with SendPort-based callback from native function.
  Future<int> asyncExample(int value) {
    final completer = Completer<int>();

    final callbackPort = ReceivePort()
      ..listen((dynamic msg) {
        completer.complete(msg);
      });

    // Call native function via getter.
    _asyncExample(value, callbackPort.sendPort.nativePort);

    return completer.future;
  }

  // Getter helpers: wrapping DynamicLibrary#lookup
  //  and Pointer<NativeFunction>#asFunction

  AsyncExample get _asyncExample {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<AsyncExampleNative>>('async_example');
    return nativeFnPointer.asFunction<AsyncExample>();
  }

  InitDartApi get _initDartApi {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<InitDartApiNative>>('init_dart_api_dl');
    return nativeFnPointer.asFunction<InitDartApi>();
  }
}
