import 'package:test/test.dart';
import '../bin/async_callback_test_integration.dart';

void main() {
  // print("test_main:5");
  // test('async_rpc_callback_proof_of_concept', () {
  //   var expectedValue = 12;
  //   var actualValue = 0;
  //
  //   Function(int) testCallback = (int value) {
  //     print("test_main->testCallback->fn_body:11");
  //     actualValue = value;
  //   };
  //
  //   print("test_main->client_SendFile():15");
  //   var integration = RpcIntegration();
  //   var result = integration.client_SendFile(expectedValue);
  //   print("test_main->client_SendFile()_done:17");
  //   result.then((int _value) {
  //     testCallback(_value);
  //
  //     print("test_main->result.then->fn_body:19");
  //     expectAsync1((_) {
  //       print("test_main->result.then->expectAsync0():21");
  //       expect(actualValue, equals(expectedValue));
  //     }, count: 1)();
  //   });
  // }, timeout: Timeout(Duration(seconds: 1)));
}
