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
import '../bin/PriorityMessageBox.dart';

void main() async
{
  test('Construct', () async {
    final Completer<void> messageCompleter = Completer<void>();
    List<String> receivedMessages = [];

    void messageCallback(PriorityMessage message) {
      print('Processed: ${message.message} with priority ${message.priority}');
      receivedMessages.add( message.message );
      if( receivedMessages.length == 3 ){
        messageCompleter.complete();
      }
    }

    final mailbox = PriorityMailbox(onMessageProcessed: messageCallback);

    final mes1_prio_3 = "Low priority";
    final mes2_prio_1 = "High priority";
    final mes3_prio_2 = "Medium priority";

    mailbox.send(3, mes1_prio_3);
    mailbox.send(1, mes2_prio_1);
    mailbox.send(2, mes3_prio_2);

    await messageCompleter.future;
    expect(receivedMessages.removeAt(0), equals(mes2_prio_1));
    expect(receivedMessages.removeAt(0), equals(mes3_prio_2));
    expect(receivedMessages.removeAt(0), equals(mes1_prio_3));
  });
}

