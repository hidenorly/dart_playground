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
import 'package:grpc/grpc.dart';
import '../lib/grpc_idl.pbgrpc.dart';

Future<void> main() async {
  final channel = ClientChannel(
    'localhost',
    port: 50051,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );

  final stub = MyServiceClient(channel);
  try {
    // invoke method1
    final response = await stub.method1(MyRequest()..text = 'from Dart client');
    print('Server Response: \"${response.receivedText}\"');

    // invoke shutdown method
    await stub.shutdown(EmptyMessage());
  } catch (e) {
    print('Caught error: $e');
  }
  await channel.shutdown();
}