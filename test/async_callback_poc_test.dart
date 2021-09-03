import 'package:test/test.dart';
import 'package:async_callback_test_integration/native_async.dart';
import 'package:async_callback_test_integration/isolate_rpc_async.dart';

void main() {
  group('async callback proof-of-concepts', () {
    test('native callbacks to dart via SendPort message passing', () async {
      final expectedValue = 760;
      final nativeAsync = NativeAsync();

      final actualValue = await nativeAsync.asyncExample(expectedValue);
      await asyncSleep(100);
      expect(actualValue, equals(expectedValue));
    }, timeout: Timeout(Duration(seconds: 1)));

    test('callbacks via isolate_rpc', () async {
      final expectedValue = 12;
      final isolateAsync = IsolateRpcAsync();

      final actualValue = await isolateAsync.asyncExample(expectedValue);
      expect(actualValue, equals(expectedValue));
    });
  }, timeout: Timeout(Duration(seconds: 2)));
}

Future asyncSleep(int ms) {
  return Future.delayed(Duration(milliseconds: ms));
}
