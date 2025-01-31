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

abstract class Task {
  final int id;
  bool isRunning = false;
  bool stopRunning = false;

  Task(this.id);

  void onExecute();

  void execute(SendPort sendPort) async {
    isRunning = true;
    onExecute();
    sendPort.send(id);
    isRunning = false;
  }
}

class CExampleTask extends Task {
  CExampleTask(int id) : super(id);

  @override
  void onExecute() async {
    print('Task $id is running...');
    for (int i = 0; i < 1000; i++) {
      if (stopRunning) break;
      await Future.delayed(Duration(milliseconds: 1));
    }
  }
}

class TaskManager {
  final int maxThreads;
  final List<Task> tasks = [];
  final Map<int, Isolate> activeTasks = {};
  bool stopping = false;
  final ReceivePort receivePort = ReceivePort();
  bool disposed = false;

  TaskManager(this.maxThreads) {
    receivePort.listen((taskId) {
      _onTaskCompletion(taskId);
    });
  }

  void addTask(Task task) {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    tasks.add(task);
  }

  void cancelTask(int taskId) {
    if (activeTasks.containsKey(taskId)) {
      tasks.firstWhere((task) => task.id == taskId).stopRunning = true;
      activeTasks[taskId]?.kill(priority: Isolate.immediate);
      activeTasks.remove(taskId);
      print('Task $taskId canceled.');
    }
    tasks.removeWhere((task) => task.id == taskId);
  }

  void executeAllTasks() async {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    stopping = false;
    while (activeTasks.length < maxThreads && tasks.isNotEmpty) {
      var task = tasks.removeAt(0);
      var isolate = await Isolate.spawn(_runTask, [task.id, receivePort.sendPort]);
      activeTasks[task.id] = isolate;
    }
  }

  void stopAllTasks() {
    stopping = true;
    for (var task in tasks) {
      task.stopRunning = true;
    }
    for (var isolate in activeTasks.values) {
      isolate.kill(priority: Isolate.immediate);
    }
    activeTasks.clear();
    print('All tasks stopped.');
  }

  void dispose() {
    if(disposed) return;

    disposed = true;
    stopAllTasks();
    receivePort.close();
    print('TaskManager disposed.');
  }

  void _onTaskCompletion(int taskId) {
    print('Task $taskId completed.');
    activeTasks.remove(taskId);
    if (!stopping) {
      executeAllTasks();
    }
  }
}

void _runTask(List<dynamic> args) {
  int taskId = args[0];
  SendPort sendPort = args[1];
  CExampleTask(taskId).execute(sendPort);
}

void main() async {
  TaskManager taskManager = TaskManager(2);
  taskManager.addTask(CExampleTask(1));
  taskManager.addTask(CExampleTask(2));
  taskManager.addTask(CExampleTask(3));
  taskManager.addTask(CExampleTask(4));
  
  taskManager.executeAllTasks();
  await Future.delayed(Duration(seconds: 1));
  taskManager.stopAllTasks();
  taskManager.dispose();
}
