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
import 'dart:convert';
import '../bin/json_rpc_server.dart';


void launch_server(dynamic arg) async {
  await startJsonRpcServer();
}

void main() async
{
  test('Construct&call sum & call shutdown', () async {
    var isolate = await Isolate.spawn(launch_server, null);

    final socket = await WebSocket.connect('ws://localhost:8080');
    print('Connected to WebSocket Server');

    // Create a completer to wait for the response
    final Map<int, Completer<int>> completers = {};

    // Listen for the response
    socket.listen((message) {
      final response = jsonDecode(message);

      // Complete with the result if the ID matches
      if( response.containsKey('id') && response.containsKey('result') ) {
        completers[response['id']]?.complete(response['result']);
      }
    });

    Future<int> sendRequestAndReceive(WebSocket socket, int requestId, String method, List<dynamic> params) async {
      var request = {
        'jsonrpc': '2.0',
        'method': method,
        'params': params,
        'id': requestId,
      };

      final completer = completers[requestId] = Completer<int>();
      // Encode the request to bytes
      socket.add(jsonEncode(request));

      // Wait for the result or error
      return await completer.future;
    }

    int requestId = 0;

    // send request
    int result = await sendRequestAndReceive(socket, ++requestId, 'sum', [10, 20]); // expect: 30
    expect(result, 30);
    result = await sendRequestAndReceive(socket, ++requestId, 'sum', [5, 15]);  // expect: 20
    expect(result, 20);
    result = await sendRequestAndReceive(socket, ++requestId, 'shutdown', []);  // expect: exit the server

    await Future.delayed(Duration(seconds: 2));
    socket.close();
  });
}

