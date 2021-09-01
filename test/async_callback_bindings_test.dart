import 'package:test/test.dart';
import '../bin/async_callback_test_integration.dart';

void main() {
  test('async_bindings_callback_proof_of_concept', () async {
    final expectedValue = 760;
    final integration = BindingIntegration();

    final actualValue = await integration.testBinding(expectedValue);
    await asyncSleep(500);
    // expect(actualValue, equals(expectedValue));
  }, timeout: Timeout(Duration(seconds: 1)));
}

Future asyncSleep(int ms) {
  return Future.delayed(Duration(milliseconds: ms));
}
