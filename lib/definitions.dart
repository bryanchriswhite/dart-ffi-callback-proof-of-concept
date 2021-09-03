import 'dart:ffi';

typedef AsyncExampleNative = Void Function(Int32, IntPtr);
typedef AsyncExample = void Function(int, int);

typedef InitDartApiNative = IntPtr Function(Pointer<Void>);
typedef InitDartApi = int Function(Pointer<Void>);

abstract class AsyncInterface {
  Future<int> asyncExample(int value);
}
