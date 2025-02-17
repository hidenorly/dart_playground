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
import 'dart:convert';

Future<void> startClient() async {
  final socket = await WebSocket.connect('ws://localhost:8080');
  print('Connected to WebSocket Server');

  int requestId = 1;

  // sendRequest
  void sendRequest(String method, List<dynamic> params) {
    var request = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': requestId++
    };
    socket.add(jsonEncode(request));
  }

  // reveiver
  socket.listen((message) {
    final response = jsonDecode(message);
    print('Received Response: $response');
  });

  // send request
  sendRequest('sum', [10, 20]); // expect: 30
  sendRequest('sum', [5, 15]);  // expect: 20
  sendRequest('shutdown', []);  // expect: exit the server

  await Future.delayed(Duration(seconds: 2));
  socket.close();
}

void main() {
  startClient();
}
