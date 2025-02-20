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

import 'package:test/test.dart';
import '../bin/ffi_sharedbuf.dart';
import 'dart:isolate';
import 'dart:io';
import 'package:ffi/ffi.dart';



void main2(SendPort sendPort)
{
  final recvPort = ReceivePort();
  expect(recvPort, isA<ReceivePort>());
  recvPort.listen( (shmId) {
    print("main2::shmId=${shmId}");
    // create the shared buffer
    var result = shm_create(shmId, 1024, false);
    expect(result, equals(true));

    print("main2::shared buffer is created");
    // read the buffer
    final shared_buffer_ptr = shm_read(shmId);
    expect(shared_buffer_ptr!=null, equals(true));
    final readBuf = shared_buffer_ptr.toDartString();
    expect(readBuf, equals("Hello from Dart"));
    expect(shm_close(shmId), equals(true));
    exit(0);
  } );
  sendPort.send(recvPort.sendPort);
}


void main()
{
  test('Construct', () async {
    final recvPort = ReceivePort();

    // get available shared memory project id
    int shmId = shm_get_free_slot();
    expect(shmId>=0 && shmId<=255, equals(true));

    // create the shared buffer
    bool result = shm_create(shmId, 1024, false);
    expect(result, equals(true));
    if( result ){
      final message = "Hello from Dart";
      // write to the shared buffer
      expect(shm_write(shmId, message.toNativeUtf8(), message.length), equals(true));

      // read the buffer
      final shared_buffer_ptr = shm_read(shmId);
      expect(shared_buffer_ptr!=null, equals(true));
      final readBuf = shared_buffer_ptr.toDartString();
      expect(readBuf, equals(message));

      recvPort.listen( (sendPort) {
        sendPort.send(shmId);
      } );

      Future.delayed(Duration(seconds: 1), () async {
        final isolate = await Isolate.spawn(main2, recvPort.sendPort, debugName: "secondary_isolate");
        expect(isolate!=null, equals(true));
        });
    }
  });
}
