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


struct NativeArgument {
    int data;
    uint8_t* buf;
};


class FFIThreadTest
{
protected:
  std::shared_ptr<std::thread> mpThread;
  int64_t mPort;
  int mData;
  std::string mText;

public:
  FFIThreadTest(int64_t port, NativeArgument* pArg):mPort(port){
    if(pArg){
      mData = pArg->data;
      mText = std::string((char*)pArg->buf);
    }
  };

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
    std::cout << "arg.data=" << pThis->mData << std::endl;
    std::cout << "arg.buf=" << pThis->mText << std::endl;
    std::this_thread::sleep_for(std::chrono::microseconds(2000));
    auto end = std::chrono::high_resolution_clock::now();
    int duration = static_cast<int>(duration_cast<std::chrono::microseconds>(end - start).count());
    if(pThis && pThis->mPort && Dart_PostCObject_DL){
      std::cout << "FFIThreadTest::execute::send message" << std::endl;
      Dart_CObject message;
      message.type = Dart_CObject_kInt64;
      message.value.as_int64 = duration;
      Dart_PostCObject_DL(pThis->mPort, &message);
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

  DART_EXPORT void start_thread(int64_t port, NativeArgument* pArg)
  {
    FFIThreadTest* pTest = new FFIThreadTest(port, pArg); // self destruct
    if(pTest){
      pTest->execute();
    }
  }
}


