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

// load libffisharedbuf shared library
final DynamicLibrary nativeLib = DynamicLibrary.open(
    Platform.isMacOS ? "libffisharedbuf.dylib" :
    Platform.isLinux ? "libffisharedbuf.so" :
    "libffisharedbuf.dll");

final initializeApi     = nativeLib.lookupFunction<IntPtr Function(Pointer<Void>), int Function(Pointer<Void>)>("InitDartApiDL");

typedef C_shm_get_free_slot = Int32 Function();
typedef D_shm_get_free_slot = int Function();

typedef C_shm_create        = Bool Function(Int32, Int32, Bool);
typedef D_shm_create        = bool Function(int, int, bool);

typedef C_shm_write         = Bool Function(Int32, Pointer<Utf8>, Int32);
typedef D_shm_write         = bool Function(int, Pointer<Utf8>, int);

typedef C_shm_read          = Pointer<Utf8> Function(Int32);
typedef D_shm_read          = Pointer<Utf8> Function(int);

typedef C_shm_close         = Bool Function(Int32);
typedef D_shm_close         = bool Function(int);

final shm_get_free_slot = nativeLib.lookup<NativeFunction<C_shm_get_free_slot>>("shm_get_free_slot").asFunction<D_shm_get_free_slot>();
final shm_create        = nativeLib.lookup<NativeFunction<C_shm_create>>("shm_create").asFunction<D_shm_create>();
final shm_write         = nativeLib.lookup<NativeFunction<C_shm_write>>("shm_write").asFunction<D_shm_write>();
final shm_read          = nativeLib.lookup<NativeFunction<C_shm_read>>("shm_read").asFunction<D_shm_read>();
final shm_close         = nativeLib.lookup<NativeFunction<C_shm_close>>("shm_close").asFunction<D_shm_close>();


void main2(SendPort sendPort)
{
  print("isolated main2");
  final recvPort = ReceivePort();
  recvPort.listen( (shmId) {
    print("main2::shmId=${shmId}");
    // create the shared buffer
    shm_create(shmId, 1024, false);
    print("main2::shared buffer is created");
    // read the buffer
    final shared_buffer_ptr = shm_read(shmId);
    print("main2::shared_buffer_ptr=${shared_buffer_ptr}");
    final readBuf = shared_buffer_ptr.toDartString();
    print("main2::read data = ${readBuf}");
    // dispose the shared memory!!!
    shm_close(shmId);
    exit(0);
  } );
  sendPort.send(recvPort.sendPort);
}


void main() async
{
  final recvPort = ReceivePort();

  // get available shared memory project id
  int shmId = shm_get_free_slot();
  print("main1::available free slot is ${shmId}");

  // create the shared buffer
  if( shm_create(shmId, 1024, false) ){
    final message = "Hello from Dart";
    // write to the shared buffer
    shm_write(shmId, message.toNativeUtf8(), message.length);

    // read the buffer
    final shared_buffer_ptr = shm_read(shmId);
    print("main1::shared_buffer_ptr=${shared_buffer_ptr}");
    final readBuf = shared_buffer_ptr.toDartString();
    print("main1::read data = ${readBuf}");

    recvPort.listen( (sendPort) {
      sendPort.send(shmId);
    } );

    Future.delayed(Duration(seconds: 1), () async {
      final isolate = await Isolate.spawn(main2, recvPort.sendPort, debugName: "secondary_isolate");
      });
  }
}
