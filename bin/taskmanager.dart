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
import 'dart:collection';
import 'dart:io';

class Task {
  bool isRunning = false;
  bool stopRunning = false;
  TaskManager? taskManager;

  Future<void> execute() async {
    stopRunning = false;
    isRunning = true;
    await onExecute();
    await onComplete();
    _onComplete();
    isRunning = false;
    stopRunning = false;
  }

  Future<void> onExecute() async {}

  Future<void> onComplete() async {}

  void _onComplete() {
    taskManager?._onTaskCompletion(this);
  }

  void cancel() {
    if (isRunning) {
      stopRunning = true;
    }
  }
}

class TaskManager {
  final int maxThreads;
  int numOfRunningTasks = 0;
  bool stopping = false;
  final List<Task> tasks = [];
  final Map<Task, Future<void>> taskThreads = {};

  TaskManager(this.maxThreads);

  void addTask(Task task) {
    task.taskManager = this;
    tasks.add(task);
  }

  void cancelTask(Task task) {
    if (taskThreads.containsKey(task)) {
      task.cancel();
      taskThreads.remove(task);
      tasks.remove(task);
    }
  }

  Future<void> executeAllTasks() async {
    stopping = false;
    if (numOfRunningTasks < maxThreads) {
      List<Task> candidateTasks = [];
      for (var task in tasks) {
        if (!task.isRunning && numOfRunningTasks < maxThreads) {
          candidateTasks.add(task);
          numOfRunningTasks++;
        }
      }
      for (var task in candidateTasks) {
        taskThreads[task] = task.execute();
      }
    }
  }

  Future<void> stopAllTasks() async {
    stopping = true;
    while (isRunning()) {
      for (var task in tasks) {
        if (task.isRunning) {
          task.cancel();
        }
      }
      await Future.delayed(Duration(milliseconds: 1));
    }
  }

  void _onTaskCompletion(Task task) {
    cancelTask(task);
    if (!stopping) {
      executeAllTasks();
    }
  }

  bool isRunning() {
    return tasks.any((task) => task.isRunning);
  }

  bool isRemainingTasks() {
    return tasks.isNotEmpty;
  }

  Future<void> finalize() async {
    await stopAllTasks();
    tasks.clear();
  }
}




class MyTask extends Task {
  @override
  Future<void> onExecute() async {
    print("MyTask is running...");
    for (int i = 0; i < 1000; i++) {
      int j = i * i;
      if (stopRunning) break;
      await Future.delayed(Duration(milliseconds: 1));
    }
  }
}

Future<void> main() async {
  print("Hello, World!");
  var taskManager = TaskManager(4);
  taskManager.addTask(MyTask());
  taskManager.addTask(MyTask());
  taskManager.addTask(MyTask());
  taskManager.addTask(MyTask());
  await taskManager.executeAllTasks();
  await Future.delayed(Duration(seconds: 1));
  await taskManager.finalize();
}
