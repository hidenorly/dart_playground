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
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:grpc/grpc.dart';
import '../bin/grpc_server.dart';
import '../lib/grpc_idl.pbgrpc.dart';


void launch_server(dynamic arg) async {
  final receiver = ReceivePort();
  receiver.listen( (mes){
    if( mes=="shutdown" ){
      exit(1);
    }
  });

  final server = Server([MyService(receiver.sendPort)]);
  await server.serve(port: 50051);
  print('gRPC Server listening on port 50051...');
}


void main() async
{
  test('Construct&call method1 & call shutdown', () async {
    var isolate = await Isolate.spawn(launch_server, null);

    final channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    final stub = MyServiceClient(channel);
    try {
      // invoke method1
      final response = await stub.method1(MyRequest()..text = 'from Dart client');
      expect( response.receivedText, 'Received text:from Dart client' );

      // invoke shutdown method
      await stub.shutdown(EmptyMessage());
    } catch (e) {
      print('Caught error: $e');
    }
    await channel.shutdown();
  });
}

