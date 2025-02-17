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
import 'package:grpc/grpc.dart';
import '../lib/grpc_idl.pbgrpc.dart';


class MyService extends MyServiceBase {
  final SendPort sendPort;
  MyService(SendPort this.sendPort){}
  @override
  Future<MyResponse> method1(ServiceCall call, MyRequest request) async {
    print("Received: \"${request.text}\"");
    return MyResponse()..receivedText = 'Received text:${request.text}';
  }

  @override
  Future<EmptyMessage> shutdown(ServiceCall call, EmptyMessage request) async {
    print('Received: shutdown request.');
    this.sendPort.send("shutdown");
    return EmptyMessage();
  }
}

Future<void> main() async {
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
