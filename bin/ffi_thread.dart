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


final Map<int, ReceivePort> port_mapper = {};

// define callback
void nativeCallback(int port, int value) {
    print("nativeCallback::port=${port}, value=${value}");
    ReceivePort? recv_port = port_mapper?[port];
    print("sendPort=${recv_port.toString()}");
    recv_port?.sendPort.send(value);
}
// -- Convert the nativeCallback to callbackPointer(=Pointer<NativeFunction<>>)
//final Pointer<NativeFunction<Void Function(Int64, Int32)>> callbackPointer = Pointer.fromFunction<Void Function(Int64, Int32)>(nativeCallback);
typedef NativeCallbackFunc = Void Function(Int64, Int32);
typedef NativeCallback = void Function(int, int);
final callbackPointer = NativeCallable<NativeCallbackFunc>.isolateLocal(nativeCallback).nativeFunction;

final initializeApi = nativeLib.lookupFunction<IntPtr Function(Pointer<Void>), 
     int Function(Pointer<Void>)>("InitDartApiDL"); 

void main() async {
    initializeApi(NativeApi.initializeApiDLData);

    final ReceivePort receivePort = ReceivePort();

    receivePort.listen((message) {
        print("Dart: received message: $message");
        exit(0);
    });

    port_mapper[receivePort.sendPort.nativePort] = receivePort;
    print("native_port=${receivePort.sendPort.nativePort}");
    startNativeThread(receivePort.sendPort.nativePort, callbackPointer);

    //exit(0);
}
