import 'package:test/test.dart';
import '../bin/async_callback_test_integration.dart';

void main() async {
  test('async_bindings_callback_proof_of_concept', () {
    final expectedValue = 760;
    final integration = BindingIntegration();

    final result = integration.testBinding(expectedValue);
    result.then((_) {
      // testCallback(_value);
      expectAsync0(() {
        // expect(actualValue, equals(expectedValue));
      }, count: 1)();
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}