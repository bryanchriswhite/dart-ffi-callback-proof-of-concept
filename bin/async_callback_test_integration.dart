import 'dart:ffi';
import 'dart:io';

import 'package:isolate_rpc/classes/Message.dart';
import 'package:isolate_rpc/isolate_rpc.dart';

const TEST_SIGNAL = 'test_signal';
const TEST_RPC = 'test_rpc';
const defaultRpcTimeout = 50;

RpcProvider? local;
RpcProvider? remote;

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
      print("ERROR: ");
      print(args);
    });

    print("main->registerSignalHandler():29");
    remote?.registerRpcHandler(TEST_RPC, (value) {
      print("main->registerSignalHandler->fn_body:29");
      return value;
    });
  }

  Future<int> client_SendFile(int value) async {
    print("main->client_SendFile->local.rpc():35");
    dynamic _value = await local?.rpc(TEST_RPC, value);
    print(_value);
    print("main->client_SendFile->local.rpc()_done:37");
    return _value;
  }

  void _localDispatch(MessageClass message, List<dynamic>? transfer) {
    print("main->localDispatch:22");
    _remote.dispatch(message);
  }

  void _remoteDispatch(MessageClass message, List<dynamic>? transfer) {
    print("main->remoteDispatch:22");
    _local.dispatch(message);
  }
}

typedef TestBindingFunc = Void Function(Int32);
typedef TestBinding = void Function(int);

class BindingIntegration {
  late final DynamicLibrary _dl;

  BindingIntegration() {
    _dl = dlOpen();
  }

  static DynamicLibrary dlOpen() {
    // TODO: - [ ] using platform-specific paths
    // TODO: - [ ] cleaned up build output paths and add to .gitignore file
    return DynamicLibrary.open('./libbindings.so');
  }

  Future<void> testBinding(int value) async {
    return _testBinding(value);
  }

  TestBinding get _testBinding {
    final nativeFnPointer =
        _dl.lookup<NativeFunction<TestBindingFunc>>('test_binding_func');
    return nativeFnPointer.asFunction<TestBinding>();
  }
}
