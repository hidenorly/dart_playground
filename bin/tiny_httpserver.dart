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

class HttpResponseHandler {
  final String path;
  late Function(HttpRequest request) onHandle;

  HttpResponseHandler(this.path);
}

class HttpServerWrapper {
  final int port;
  final List<HttpResponseHandler> handlers = [];

  HttpServerWrapper(this.port);

  void addHandler(HttpResponseHandler handler) {
    handlers.add(handler);
  }

  Future<void> listen() async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    print('Server listening on port $port');

    await for (HttpRequest request in server) {
      final path = request.uri.path;
      final handler = handlers.firstWhere(
        (h) => path.startsWith(h.path),
        orElse: () => HttpResponseHandler('')..onHandle = (req) => req.response
          ..statusCode = HttpStatus.notFound
          ..write('404 Not Found')
          ..close(),
      );
      handler.onHandle(request);
    }
  }
}

void main() {
  final server = HttpServerWrapper(8080);

  final settingHandler = HttpResponseHandler('/settings');
  settingHandler.onHandle = (HttpRequest request) {
    final args = request.uri.queryParameters;
    request.response.write('Settings handler:${request.uri}\n');
    args.forEach((key, value) {
      request.response.write('$key = $value\n');
    });
    request.response.close();
  };

  final switchHandler = HttpResponseHandler('/switch');
  switchHandler.onHandle = (HttpRequest request) {
    final args = request.uri.queryParameters;
    request.response.write('Switch handler:${request.uri}\n');
    args.forEach((key, value) {
      request.response.write('$key = $value\n');
    });
    request.response.close();
  };

  server.addHandler(settingHandler);
  server.addHandler(switchHandler);

  server.listen();
}
