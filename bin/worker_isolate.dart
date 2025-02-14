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


abstract class ITask {
  int id = 0;
  final String desc;
  Future<void> onExecute() async{ print("onExecute::${id}"); }
  Future<void> onComplete() async{ print("onComplete::${id}"); }
  ITask(this.desc){}
}

class IpcMessage
{
  final String command;
  final dynamic data;
  IpcMessage(this.command, this.data){}
}

class TaskExecutor
{
  late ReceivePort mReceivePort;
  final SendPort mSendPort;
  final int id;

  TaskExecutor(this.id, SendPort this.mSendPort){
  }

  void _onTaskExecute(ITask task) async{
    await task.onExecute();
    await task.onComplete();
    IpcMessage msg = IpcMessage("completion", this.id);
    mSendPort.send(msg);
  }

  static Future<void> run(TaskExecutor pThis) async
  {
    pThis.mReceivePort = ReceivePort();
    // report the worker_port
    pThis.mSendPort.send( IpcMessage("worker_port", [pThis.id, pThis.mReceivePort.sendPort]) );

    pThis.mReceivePort.listen((mes) {
      if( mes.command == "execute" ){
        pThis._onTaskExecute(mes.data);
      } else if (mes.command == "exit" ){
        print("executor(${pThis.id}): exit received.");
        pThis.mReceivePort.close();
        Isolate.exit();
      }
    });
  }
}

class TaskManager {
  final int maxConcurrency;
  final List<ITask> tasks = [];
  final ReceivePort mReceivePort = ReceivePort();
  final Map<int, SendPort?> mWorkerPorts = {};
  final Map<int, TaskExecutor?> mWorkerExecutor = {};
  final Map<int, Isolate?> mWorkerIsolates = {};
  final Map<int, bool> mWorkerActive = {};

  Completer<void> _completion = Completer<void>();
  bool disposed = false;
  bool stopping = false;

  TaskManager._(this.maxConcurrency);

  static Future<TaskManager> create(int maxConcurrency) async {
    final manager = TaskManager._(maxConcurrency);

    manager.mReceivePort.listen((mes) {
      print("recv:${mes.command}:${mes.data.toString()}");
      if( mes.command == "worker_port" ){
        manager.mWorkerPorts[mes.data[0]] = mes.data[1]; // #0:id, #1:sendPort
      } else if( mes.command == "completion" ){
        manager._onTaskCompletion(mes.data); // task_executor_id
      }
    });

    for(int i=0; i<manager.maxConcurrency; i++){
      TaskExecutor executor = TaskExecutor(i, manager.mReceivePort.sendPort);
      manager.mWorkerExecutor[i] = executor;
      manager.mWorkerActive[i] = false;
      manager.mWorkerIsolates[i] = await Isolate.spawn(TaskExecutor.run, executor);
    }

    return manager;
  }


  void execSub()
  {
    if(disposed){
      throw Exception("TaskManager is already disposed.");
    }
    if(stopping) return;
    List<int> readyIsolates = [];
    for(int i=0; i<mWorkerActive.length; i++){
      if( false == mWorkerActive[i] && mWorkerPorts[i]!=null){
        readyIsolates.add(i);
      }
    }
    for( int readyExecutorIndex in readyIsolates ){
      var task = tasks.isNotEmpty ? tasks.removeAt(0) : null;
      if(task != null){
        mWorkerActive[readyExecutorIndex] = true;
        print("executing...${task.desc} on ${readyExecutorIndex}");
        mWorkerPorts[readyExecutorIndex]?.send(IpcMessage("execute", task));
      }
    }
  }

  void _onTaskCompletion(int task_executor_id){
    mWorkerActive[task_executor_id] = false;
    execSub();
    if (tasks.isEmpty && !_completion.isCompleted) {
      _completion.complete();
    }
  }

  void addTask(ITask task) {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    task.id = task.hashCode;
    tasks.add(task);
    if (_completion.isCompleted) {
      _completion.completeError('Completion was already completed, resetting.');
      _completion = Completer<void>();
    }
  }

  void executeAllTasks() async {
    if(disposed){
      throw Exception("TaskManager is disposed and cannot accept new tasks.");
    }
    stopping = false;
    execSub();
  }

  Future<void> finalize() async {
    if(disposed) return;

    await _completion.future;
    disposed = true;
    for(int i=0; i<mWorkerPorts.length; i++){
        mWorkerPorts[i]?.send(IpcMessage("exit", null));
        mWorkerPorts[i] = null;
        mWorkerExecutor[i] = null;
        mWorkerIsolates[i] = null;
    }
    mReceivePort.close();
    print('TaskManager finalized.');
  }

  void stopAllTasks() {
    stopping = true;
    if (!_completion.isCompleted) {
      _completion.complete();
    }
  }

  void cancelTask(ITask task) {
    tasks.remove(task);
  }
}

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
}

