import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io';

import 'package:isolate_rpc/classes/Message.dart';
import 'package:isolate_rpc/isolate_rpc.dart';

const TEST_SIGNAL = 'test_signal';
const TEST_RPC = 'test_rpc';
const defaultRpcTimeout = 50;

class RpcIntegration {
  static const DefaultRpcTimeout = 50;

  late RpcProvider _local;
  late RpcProvider _remote;

  // TODO: look up how to simplify
  RpcIntegration() {
    _local = RpcProvider(_localDispatch, DefaultRpcTimeout);
    _remote = RpcProvider(_remoteDispatch, DefaultRpcTimeout);

    // TODO: think through error handling
    RpcProvider.error.subscribe((args) {
      print("ERROR: $args");
    });

    _remote.registerRpcHandler(TEST_RPC, (value) {
      return value;
    });
  }

  Future<int> asyncExample(int value) async {
    dynamic _value = await _local.rpc(TEST_RPC, value);
    return _value;
  }

  void _localDispatch(MessageClass message, List<dynamic>? transfer) {
    _remote.dispatch(message);
  }

  void _remoteDispatch(MessageClass message, List<dynamic>? transfer) {
    _local.dispatch(message);
  }
}

typedef TestBindingNative = Void Function(Int32, IntPtr);
typedef AsyncExample = void Function(int, int);

typedef InitDartApiNative = IntPtr Function(Pointer<Void>);
typedef InitDartApi = int Function(Pointer<Void>);

typedef RegisterSendPortNative = Void Function(Int64 sendPort);
typedef RegisterSendPort = void Function(int sendPort);

class BindingIntegration {
  late final DynamicLibrary _dl;
  late final ReceivePort _receivePort;

  BindingIntegration() {
    _dl = dlOpen();
    _initDartApi(NativeApi.initializeApiDLData);
  }

  static DynamicLibrary dlOpen() {
    // TODO: - [ ] using platform-specific paths
    // TODO: - [ ] cleaned up build output paths and add to .gitignore file
    return DynamicLibrary.open('./libbindings.so');
  }

  Future<int> asyncExample(int value) async {
    final _completer = Completer<int>();
    _receivePort = ReceivePort()..listen((dynamic msg) {
      _completer.complete(msg);

      // TODO: isolate_rpc
      // _rpc = RpcProvider(dispatchFunction);
      // _rpc.registerRpcHandler(ACTION_NAME, handlerFunction);
    // unregister on complete!
    });

    // NB: sends message on send port when complete.
    _asyncExample(value, _receivePort.sendPort.nativePort);

    return _completer.future;
  }

  AsyncExample get _asyncExample {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<TestBindingNative>>('async_example');
    return nativeFnPointer.asFunction<AsyncExample>();
  }

  InitDartApi get _initDartApi {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<InitDartApiNative>>('init_dart_api_dl');
    return nativeFnPointer.asFunction<InitDartApi>();
  }
}
