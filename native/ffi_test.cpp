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

#include <thread>
#include <chrono>
#include <iostream>
#include <memory>
#include <dart_api.h>
#include <dart_api_dl.h>

typedef void (*DartCallback)(int64_t port, int value);


class FFIThreadTest
{
protected:
  std::shared_ptr<std::thread> mpThread;
  DartCallback mpCallback;
  int mPort;

public:
  FFIThreadTest(int64_t port, DartCallback cb):mPort(port), mpCallback(cb){};

  virtual ~FFIThreadTest(){
    if( mpThread ){
      if( mpThread->joinable()){
        mpThread->detach();
      }
      mpThread.reset();
    }
  }

  static void doSomething(FFIThreadTest* pThis){
    std::cout << "FFIThreadTest::execute" << std::endl;
    auto start = std::chrono::high_resolution_clock::now();
    // do somethings
    std::this_thread::sleep_for(std::chrono::microseconds(1000));
    auto end = std::chrono::high_resolution_clock::now();
    int duration = static_cast<int>(duration_cast<std::chrono::microseconds>(end - start).count());
    if(pThis && pThis->mpCallback){
      //Dart_CObject message;
      //message.type = Dart_CObject_kInt64; // 例: int64 を送信
      //message.value.as_int64 = duration;
//      Dart_Send(pThis->mPort, &message);
      //Dart_Handle handle = Dart_NewInteger(duration);
      //Dart_Post(pThis->mPort, handle);
      pThis->mpCallback(pThis->mPort, duration);
    }
    std::cout << "FFIThreadTest::execute::bail" << std::endl;
    delete pThis;
  }

  void execute(){
    mpThread = std::make_shared<std::thread>(doSomething, this);
    mpThread->detach();
  }
};

extern "C"
{
void start_thread(int64_t port, DartCallback callback)
{
  FFIThreadTest* pTest = new FFIThreadTest(port, callback); // self destruct
  if(pTest){
    //pTest->execute();
    pTest->doSomething(pTest);
  }
}
}


