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
import 'dart:async';
import '../bin/worker_isolate.dart';


class MyTask extends ITask
{
  MyTask(String desc): super(desc);
  @override
  Future<void> onExecute() async{
    print("onExecute::${desc}");
    await Future.delayed(Duration(milliseconds: 500));
  }
  @override
  Future<void> onComplete() async{ print("onComplete::${desc}"); }
}

void main() async
{
  test('instanciate TaskManager', () async{
    TaskManager taskMan = await TaskManager.create(4);
    taskMan.addTask( MyTask("1") );
    taskMan.addTask( MyTask("2") );
    taskMan.addTask( MyTask("3") );
    taskMan.addTask( MyTask("4") );
    taskMan.addTask( MyTask("5") );
    taskMan.addTask( MyTask("6") );
    taskMan.addTask( MyTask("7") );
    taskMan.addTask( MyTask("8") );
    taskMan.addTask( MyTask("9") );
    taskMan.addTask( MyTask("10") );
    taskMan.executeAllTasks();
    await Future.delayed(Duration(seconds: 1));
    taskMan.stopAllTasks();
    await taskMan.finalize();
    });
}