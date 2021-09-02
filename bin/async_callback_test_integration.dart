import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:io';

// import 'package:isolate_rpc/classes/Message.dart';
// import 'package:isolate_rpc/isolate_rpc.dart';

const TEST_SIGNAL = 'test_signal';
const TEST_RPC = 'test_rpc';
const defaultRpcTimeout = 50;

// RpcProvider? local;
// RpcProvider? remote;

// class RpcIntegration {
//   static const DefaultRpcTimeout = 50;
//
//   late RpcProvider _local;
//   late RpcProvider _remote;
//
//   // TODO: look up how to simplify
//   RpcIntegration() {
//     _local = RpcProvider(_localDispatch, DefaultRpcTimeout);
//     _remote = RpcProvider(_remoteDispatch, DefaultRpcTimeout);
//
//     // TODO: think through error handling
//     RpcProvider.error.subscribe((args) {
//       print("ERROR: ");
//       print(args);
//     });
//
//     print("main->registerSignalHandler():29");
//     remote?.registerRpcHandler(TEST_RPC, (value) {
//       print("main->registerSignalHandler->fn_body:29");
//       return value;
//     });
//   }
//
//   Future<int> client_SendFile(int value) async {
//     print("main->client_SendFile->local.rpc():35");
//     dynamic _value = await local?.rpc(TEST_RPC, value);
//     print(_value);
//     print("main->client_SendFile->local.rpc()_done:37");
//     return _value;
//   }
//
//   void _localDispatch(MessageClass message, List<dynamic>? transfer) {
//     print("main->localDispatch:22");
//     _remote.dispatch(message);
//   }
//
//   void _remoteDispatch(MessageClass message, List<dynamic>? transfer) {
//     print("main->remoteDispatch:22");
//     _local.dispatch(message);
//   }
// }

typedef TestBindingNative = Void Function(Int32, IntPtr);
typedef TestBinding = void Function(int, int);

typedef InitDartApiNative = IntPtr Function(Pointer<Void>);
typedef InitDartApi = int Function(Pointer<Void>);

typedef RegisterSendPortNative = Void Function(Int64 sendPort);
typedef RegisterSendPort = void Function(int sendPort);

class BindingIntegration {
  int _completerId = 0;

  late final DynamicLibrary _dl;
  late final ReceivePort _receivePort;

  final Map<int, Completer> _completers = {};

  BindingIntegration() {
    _dl = dlOpen();

    _initDartApi(NativeApi.initializeApiDLData);
  }

  static DynamicLibrary dlOpen() {
    // TODO: - [ ] using platform-specific paths
    // TODO: - [ ] cleaned up build output paths and add to .gitignore file
    return DynamicLibrary.open('./libbindings.so');
  }

  Future<int> testBinding(int value) async {
    final _completer = Completer<int>();
    _receivePort = ReceivePort()..listen((dynamic msg) {
      print('Dart | ReceivePort listener');
      _completer.complete(msg);

      // TODO: isolate_rpc
      // _rpc = RpcProvider(dispatchFunction);
      // _rpc.registerRpcHandler(ACTION_NAME, handlerFunction);
    // unregister on complete!
    });

    // NB: sends message on send port when complete.
    _testBinding(value, _receivePort.sendPort.nativePort);

    return _completer.future;
  }

  TestBinding get _testBinding {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<TestBindingNative>>('test_binding_func');
    return nativeFnPointer.asFunction<TestBinding>();
  }

  InitDartApi get _initDartApi {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<InitDartApiNative>>('init_dart_api_dl');
    return nativeFnPointer.asFunction<InitDartApi>();
  }
}
