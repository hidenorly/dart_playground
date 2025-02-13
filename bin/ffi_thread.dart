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
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

// load ffitest shared library
final DynamicLibrary nativeLib = DynamicLibrary.open(
    Platform.isMacOS ? "libffithread.dylib" :
    Platform.isLinux ? "libffithread.so" :
    "ffithread.dll");

final class NativeArgument extends Struct {
  @Int32()
  external int data;

  external Pointer<Uint8> buf;
}

// resolve symbols -- start_thread
typedef StartThreadC = Void Function(Int64, Pointer<NativeArgument>);
typedef StartThreadDart = void Function(int, Pointer<NativeArgument>);
final StartThreadDart startNativeThread = nativeLib
    .lookup<NativeFunction<StartThreadC>>("start_thread")
    .asFunction();

final Map<int, ReceivePort> port_mapper = {};

final initializeApi = nativeLib.lookupFunction<IntPtr Function(Pointer<Void>), 
     int Function(Pointer<Void>)>("InitDartApiDL"); 

void main() async {
    initializeApi(NativeApi.initializeApiDLData);

    // receiver
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
        print("Dart: received message: $message");
        exit(0);
    });
    // sender port
    final nativeSendPort = receivePort.sendPort.nativePort;
    print("native_port=${nativeSendPort}");
    // store for future use
    port_mapper[nativeSendPort] = receivePort;

    // argument
    final Pointer<NativeArgument> arg = malloc<NativeArgument>();

    arg.ref.data = 10;

    final String message = "Hello from Dart";
    arg.ref.buf = malloc<Uint8>(message.length+1);
    final Uint8List buf = arg.ref.buf.asTypedList(message.length+1);
    buf.setRange(0, message.length, message.codeUnits);
    buf[message.length] = 0;

    // invoke native start_thread
    startNativeThread(receivePort.sendPort.nativePort, arg);

    // free the argument
    malloc.free(arg);
}
