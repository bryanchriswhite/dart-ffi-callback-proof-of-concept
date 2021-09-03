import 'dart:async';
import 'dart:isolate';

import 'package:isolate_rpc/classes/Message.dart';
import 'package:isolate_rpc/isolate_rpc.dart';

import 'package:async_callback_test_integration/definitions.dart';
import 'package:async_callback_test_integration/native_async.dart';

const ASYNC_EXAMPLE = 'async_example';
const DefaultRpcTimeout = 50;

class IsolateRpcAsync implements AsyncInterface {
  late final RpcProvider _provider;

  late final ReceivePort _rxPort;

  late final SendPort _txPort;

  // Will complete when `_txPort` is received and assigned.
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
    // Wait for `_txPort` to be assinged!
    await _ready.future;
    return await _provider.rpc(ASYNC_EXAMPLE, value);
  }

  void _rxListener(dynamic message) {
    // TODO: don't allow _txPort to be assigned more than once.
    //  could close existing listener and open a new one
    if (message.runtimeType != MessageClass) {
      _txPort = message;
      _ready.complete();
      return;
    }

    _provider.dispatch(message);
  }

  void _providerDispatch(MessageClass message, List<dynamic>? transfer) {
  // TODO: what about transfer?
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
        isolateProvider.dispatch(message);
      });

    // Send "remote" `SendPort` back to "local" isolate for "remote"-bound sending.
    sendPort.send(isolateRxPort.sendPort);

    // Instantiate nativeAsync in "remote" isolate context only!
    final native = NativeAsync();

    // Register rpc provider handlers to call nativeAsync members.
    // TODO: think through error handling
    isolateProvider.registerRpcHandler(ASYNC_EXAMPLE, (value) {
      return native.asyncExample(value);
    });
  }
}
