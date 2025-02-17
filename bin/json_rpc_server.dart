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

Future<void> startJsonRpcServer({int port = 8080}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('WebSocket JSON-RPC Server listening on ws://localhost:$port');

  await for (var request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      WebSocket socket = await WebSocketTransformer.upgrade(request);
      handleConnection(socket);
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..write('WebSocket connections only')
        ..close();
    }
  }
}

void handleConnection(WebSocket socket) {
  socket.listen((message) {
    try {
      final request = jsonDecode(message);
      print('Received: $request');

      var response = {'jsonrpc': '2.0', 'id': request['id']};

      if (request is Map<String, dynamic> && request['jsonrpc'] == '2.0') {
        if( request['method'] == 'sum' && request.containsKey('params')) {
          var params = request['params'];
          if (params is List && params.length == 2) {
            int result = params[0] + params[1];
            response['result'] = result;
          }
        } else if ( request['method'] == 'shutdown' ) {
          response['result'] = 'shutdown ok';
          socket.add(jsonEncode(response)); // workaround
          exit(1);
        } else {
          response['error'] = 'Invalid request';
        }
        socket.add(jsonEncode(response));
      }
    } catch (e) {
      socket.add(jsonEncode({'jsonrpc': '2.0', 'error': 'Invalid request'}));
    }
  });
}

void main() {
  startJsonRpcServer();
}
