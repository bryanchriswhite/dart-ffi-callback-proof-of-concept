import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io';

import 'package:isolate_rpc/classes/Message.dart';
import 'package:isolate_rpc/isolate_rpc.dart';

const ASYNC_EXAMPLE = 'async_example';
const DefaultRpcTimeout = 50;

//TODO: move to definitions.dart
typedef AsyncExampleNative = Void Function(Int32, IntPtr);
typedef AsyncExample = void Function(int, int);

typedef InitDartApiNative = IntPtr Function(Pointer<Void>);
typedef InitDartApi = int Function(Pointer<Void>);

abstract class AsyncInterface {
  Future<int> asyncExample(int value);
}
//---

class IsolateRpcAsync implements AsyncInterface {
  late final RpcProvider _provider;

  late final ReceivePort _rxPort;

  late final SendPort _txPort;

  late final Completer _ready;

  // TODO: look up how to simplify
  IsolateRpcAsync() {
    _provider = RpcProvider(_providerDispatch, DefaultRpcTimeout);
    _rxPort = ReceivePort()..listen(_rxListener);

    _ready = Completer();
    // TODO: consider using spawnUri (?)
    Isolate.spawn(_isolateMain, _rxPort.sendPort);
  }

  // "local" member calls rpc provider with corresponding action.
  Future<int> asyncExample(int value) async {
    await _ready.future;
    print("Dart | IsolateAsync#asyncExample:28");
    return await _provider.rpc(ASYNC_EXAMPLE, value);
  }

  void _rxListener(dynamic message) {
    // TODO: don't allow _txPort to be assigned more than once.
    //  could close existing listener and open a new one
    print("Dart | IsolateAsync#_rxListener:49 $message");
    print("runtimeType: ${message.runtimeType}");
    if (message.runtimeType != MessageClass) {
      _txPort = message;
      _ready.complete();
      return;
    }

    _provider.dispatch(message);
  }

  void _providerDispatch(MessageClass message, List<dynamic>? transfer) {
    // TODO: what about transfer?
    print("Dart | IsolateAsync#_providerDispatch:78");
    _txPort.send(message);
  }

  static void _isolateMain(dynamic sendPort) {
    // Set up "remote" rpc provider.
    final isolateProvider =
        RpcProvider((dynamic message, List<dynamic>? transfer) {
      sendPort.send(message);
    }, DefaultRpcTimeout);

    // Create response port for "remote"-bound messages from "local" isolate.
    // Listen for messages and dispatch them into "remote" provider.
    final isolateRxPort = ReceivePort()
      ..listen((dynamic message) {
        print("Dart | IsolateAsync isolateRxPort listener:52");
        isolateProvider.dispatch(message);
      });

    // Send "remote" `SendPort` back to "local" isolate for "remote"-bound sending.
    sendPort.send(isolateRxPort.sendPort);

    // Instantiate nativeAsync in "remote" isolate context only!
    final native = NativeAsync();

    // Register rpc provider handlers to call nativeAsync members.
    // TODO: think through error handling
    isolateProvider.registerRpcHandler(ASYNC_EXAMPLE, (value) {
      print("Dart | IsolateAsync ASYNC_EXAMPLE handler:65");
      return native.asyncExample(value);
    });
  }
}

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

  Future<int> asyncExample(int value) {
    print("Dart | NativeAsync#asyncExample:107");
    final completer = Completer<int>();

    final callbackPort = ReceivePort()
      ..listen((dynamic msg) {
        print("Dart | NativeAsync#asyncExample cb listener:111");
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
