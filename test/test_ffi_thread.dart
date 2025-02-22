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

import 'dart:io';
import 'dart:isolate';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import '../bin/ffi_thread.dart';


void main() {
  test('ReceivePort should receive message from native thread', () async {
    initializeApi(NativeApi.initializeApiDLData);

    final Completer<int> messageCompleter = Completer<int>();

    // Receiver
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      print("Dart: received message: $message");
      messageCompleter.complete(message);
    });

    // Sender port
    final nativeSendPort = receivePort.sendPort.nativePort;

    // Setup the Argument
    final Pointer<NativeArgument> arg = malloc<NativeArgument>();
    arg.ref.data = 10;

    final String message = "Hello from Dart";
    arg.ref.buf = malloc<Uint8>(message.length + 1);
    final Uint8List buf = arg.ref.buf.asTypedList(message.length + 1);
    buf.setRange(0, message.length, message.codeUnits);
    buf[message.length] = 0;

    // start Native Thread. wait the callback message via the receivePort
    startNativeThread(receivePort.sendPort.nativePort, arg);
    // wait the callback message
    final receivedMessage = await messageCompleter.future;

    // check
    expect((receivedMessage>2000), equals(true)); // duration is expected than 2000

    // Release the Argument
    malloc.free(arg);

    // Release the port
    receivePort.close();
  });
}
