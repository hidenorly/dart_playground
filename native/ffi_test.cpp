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
#include <dlfcn.h>


typedef void (*DartCallback)(int64_t port, int value);


class FFIThreadTest
{
protected:
  std::shared_ptr<std::thread> mpThread;
  DartCallback mpCallback;
  int64_t mPort;

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

  static bool prepare()
  {
    if(!Dart_CurrentIsolate_DL || !Dart_EnterIsolate_DL || !Dart_PostCObject_DL || !Dart_PostCObject_DL || !Dart_Post_DL ||!Dart_PostInteger_DL){
      std::cout << "Dart_* functions are not initialized yet." << std::endl;

      // workaround... (InitDartApiDL() is now working then this workaround is not required!!!)
      void* handle = dlopen(NULL, RTLD_NOW);
      std::cout << "handle:" << handle << std::endl;

      if(!Dart_PostInteger_DL){
        Dart_PostInteger_DL = (Dart_PostInteger_Type)dlsym(handle, "Dart_PostInteger");
        std::cout << "Dart_PostInteger_DL: " << Dart_PostInteger_DL << std::endl;
      }
      dlclose(handle);
    }
    return Dart_PostInteger_DL!=nullptr; // Dart_CurrentIsolate_DL && Dart_EnterIsolate_DL && Dart_PostCObject_DL && Dart_PostCObject_DL;
  }

  static void doSomething(FFIThreadTest* pThis){
    std::cout << "FFIThreadTest::execute" << std::endl;
    auto start = std::chrono::high_resolution_clock::now();
    // do somethings
    std::this_thread::sleep_for(std::chrono::microseconds(2000));
    auto end = std::chrono::high_resolution_clock::now();
    int duration = static_cast<int>(duration_cast<std::chrono::microseconds>(end - start).count());
    if(pThis && pThis->mpCallback && pThis->mPort){
//      Dart_Handle handle = Dart_NewInteger(duration); // UNABLE TO FIND THE SYMBOL
//      Dart_Post_DL(pThis->mPort, handle);

        std::cout << "Dart_CObject" << std::endl;
        Dart_CObject message;
        message.type = Dart_CObject_kInt64;
        message.value.as_int64 = duration;
        if(Dart_PostCObject_DL){
          std::cout << "Dart_PostCObject_DL" << std::endl;
          Dart_PostCObject_DL(pThis->mPort, &message);
        }

/*
      std::cout << "Dart_CurrentIsolate_DL" << std::endl;
      if(Dart_CurrentIsolate_DL){
        Dart_Isolate isolate = Dart_CurrentIsolate_DL();
        if(isolate && Dart_EnterIsolate_DL){
          std::cout << "Dart_EnterIsolate_DL" << std::endl;
          Dart_EnterIsolate_DL(isolate);
          {
            std::cout << "Dart_CObject" << std::endl;
            Dart_CObject message;
            message.type = Dart_CObject_kInt64;
            message.value.as_int64 = duration;
            if(Dart_PostCObject_DL){
              std::cout << "Dart_PostCObject_DL" << std::endl;
              Dart_PostCObject_DL(pThis->mPort, &message);
            }
          }
          if(Dart_ExitIsolate_DL){
            std::cout << "Dart_ExitIsolate_DL" << std::endl;
            Dart_ExitIsolate_DL();
          }
        }
      }
*/
//      Dart_PostInteger_DL(pThis->mPort, duration); // WORK
      //pThis->mpCallback(pThis->mPort, duration); // THIS SHOULD NOT WORK DUE TO DIFFERENT THREAD
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
DART_EXPORT intptr_t InitDartApiDL(void* data) { 
   return Dart_InitializeApiDL(data); 
 } 

DART_EXPORT void start_thread(int64_t port, DartCallback callback)
{
  std::cout << "Initializing..." << std::endl;
  bool isInitialized = FFIThreadTest::prepare();
  std::cout << "Initialized:" << (isInitialized ? "ok" : "not initialized") << std::endl;

  FFIThreadTest* pTest = new FFIThreadTest(port, callback); // self destruct
  if(pTest){
    pTest->execute();
    //pTest->doSomething(pTest);
  }
}
}


