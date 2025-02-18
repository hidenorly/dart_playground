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

import 'dart:async';
import 'package:collection/collection.dart';

class PriorityMessage {
  final int priority;
  final dynamic message;

  PriorityMessage(this.priority, this.message);
}

class PriorityMailbox {
  final PriorityQueue<PriorityMessage> _queue = PriorityQueue<PriorityMessage>((a, b) => a.priority.compareTo(b.priority));
  final StreamController<void> _controller = StreamController<void>();

  PriorityMailbox({required this.onMessageProcessed}) {
    _controller.stream.listen((_) => _processQueue());
  }

  final Function(PriorityMessage) onMessageProcessed;

  void send(int priority, dynamic message) {
    _queue.add(PriorityMessage(priority, message));
    _controller.add(null);
  }

  void _processQueue() {
    while (_queue.isNotEmpty) {
      final msg = _queue.removeFirst();
      onMessageProcessed(msg);
    }
  }
}

void main() {
  void messageCallback(PriorityMessage message) {
    print('Processed: ${message.message} with priority ${message.priority}');
  }

  final mailbox = PriorityMailbox(onMessageProcessed: messageCallback);

  mailbox.send(3, "Low priority");
  mailbox.send(1, "High priority");
  mailbox.send(2, "Medium priority");
}
