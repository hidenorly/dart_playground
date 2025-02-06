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

import 'dart:isolate';
import 'dart:async';

class TaskCompletionResult
{
  final int id;
  final int? _hash;
  final String desc;
  final dynamic result;
  TaskCompletionResult(this.id, this._hash, this.desc, this.result);
}

class Task {
  final int id;
  final String desc;
  bool isRunning = false;
  bool stopRunning = false;
  SendPort? sendPort = null;
  int? _hash = null;

  Task(this.id, [this.desc = ""]);

  dynamic onExecute() async{ return null; }

  void execute() async {
    isRunning = true;
    var result = await onExecute();
    final pack = TaskCompletionResult(this.id, this._hash, this.desc, result);
    sendPort?.send( pack );
    isRunning = false;
  }
}

class TaskManager {
  final int maxThreads;
  final List<Task> tasks = [];
  final Map<int, Isolate?> activeTasks = {};
  bool stopping = false;
  final ReceivePort receivePort = ReceivePort();
  Completer<void> _completion = Completer<void>();
  bool disposed = false;
  List<dynamic> result = [];

  TaskManager(this.maxThreads) {
    receivePort.listen((task) {
      _onTaskCompletion(task);
    });
  }

  void addTask(Task task) {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    tasks.add(task);
    if (_completion.isCompleted) {
      _completion.completeError('Completion was already completed, resetting.');
      _completion = Completer<void>();
    }
  }

  void cancelTask(Task task) {
    if (activeTasks.containsKey(task.id)) {
      task.stopRunning = true;
      activeTasks[task.id]?.kill(priority: Isolate.immediate);
      activeTasks.remove(task.id);
    }
    tasks.remove(task);
  }

  void executeAllTasks() async {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    stopping = false;
    while (activeTasks.length < maxThreads && tasks.isNotEmpty) {
      var task = tasks.removeAt(0);
      int _hash = task._hash = task.hashCode;
      task.sendPort = receivePort.sendPort;
      activeTasks[_hash] = null;
      var isolate = await Isolate.spawn(TaskManager._runTask, [task]);
      activeTasks[_hash] = isolate;
    }
  }

  void stopAllTasks() {
    stopping = true;
    for (var task in tasks) {
      task.stopRunning = true;
    }
    for (var isolate in activeTasks.values) {
      isolate?.kill(priority: Isolate.immediate);
    }
    activeTasks.clear();
    print('All tasks stopped.');
    if (!_completion.isCompleted) {
      _completion.complete();
    }
  }

  Future<void> finalize() async {
    if(disposed) return;

    await _completion.future;
    disposed = true;
    receivePort.close();
    print('TaskManager finalized.');
  }

  void _onTaskCompletion(TaskCompletionResult _result) {
    print('Task ${_result.desc} completed.');
    result.add(_result.result);
    activeTasks.remove(_result._hash);
    if (tasks.isEmpty && activeTasks.isEmpty) {
      if (!_completion.isCompleted) {
        _completion.complete();
      }
    } else if (!stopping) {
      executeAllTasks();
    }
  }

  static void _runTask(List<dynamic> args) {
    Task task = args[0];
    task.execute();
  }

  List<dynamic> getResult(){
    return result;
  }
}


class CExampleTask extends Task {
  int result = 0;
  CExampleTask(int id, [String desc = ""]) : super(id, desc);

  @override
  dynamic onExecute() async {
    print('Task $desc is running...');
    for (int i = 0; i < 1000; i++) {
      result = i;
      if (stopRunning) break;
      await Future.delayed(Duration(milliseconds: 1));
    }
    return result;
  }
}


void main() async {
  TaskManager taskManager = TaskManager(2);
  taskManager.addTask(CExampleTask(1, "1"));
  taskManager.addTask(CExampleTask(2, "2"));
  taskManager.addTask(Task(3, "3"));
  taskManager.addTask(CExampleTask(4, "4"));
  
  taskManager.executeAllTasks();
  //taskManager.stopAllTasks();
  await taskManager.finalize();
  var result = taskManager.getResult();
  for(var aResult in result){
    print(aResult.toString());
  }
}
