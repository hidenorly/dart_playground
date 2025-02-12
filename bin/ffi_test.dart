/*
  Copyright (C) 2025 hidenorly

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

// load ffitest shared library
final DynamicLibrary nativeLib = DynamicLibrary.open(
    Platform.isMacOS ? "libffitest.dylib" :
    Platform.isLinux ? "libffitest.so" :
    "ffitest.dll");

// resolve symbols -- start_thread
typedef StartThreadC = Void Function(Int64, Pointer<NativeFunction<Void Function(Int64, Int32)>>);
typedef StartThreadDart = void Function(int, Pointer<NativeFunction<Void Function(Int64, Int32)>>);
final StartThreadDart startNativeThread = nativeLib
    .lookup<NativeFunction<StartThreadC>>("start_thread")
    .asFunction();

// define callback
void nativeCallback(int port, int value) {
  //final SendPort sendPort = SendPort.fromRawNativePort(port);
  //sendPort.send(value);
  print("value=${value}");
}
// -- Convert the nativeCallback to callbackPointer(=Pointer<NativeFunction<>>)
final Pointer<NativeFunction<Void Function(Int64, Int32)>> callbackPointer =
    Pointer.fromFunction<Void Function(Int64, Int32)>(nativeCallback);

//typedef NativeCallbackFunc = Void Function(Int64, Int32);
//typedef NativeCallback = void Function(int, int);
//final callbackPointer = NativeCallable<NativeCallbackFunc>.isolateLocal(nativeCallback).nativeFunction;

final ReceivePort receivePort = ReceivePort();

void main() async {
   receivePort.listen((message) {
    print("Dart: received message: $message");
  });

  startNativeThread(receivePort.sendPort.nativePort, callbackPointer);

  exit(0);
}
