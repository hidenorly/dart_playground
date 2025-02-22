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

extern "C"
{
  DART_EXPORT intptr_t InitDartApiDL(void* data) { 
    return Dart_InitializeApiDL(data); 
  } 

  DART_EXPORT void native_c_func(int64_t port, DartCallback callback)
  {
    auto start = std::chrono::high_resolution_clock::now();
    // do somethings
    std::this_thread::sleep_for(std::chrono::microseconds(2000));
    auto end = std::chrono::high_resolution_clock::now();
    int duration = static_cast<int>(duration_cast<std::chrono::microseconds>(end - start).count());
    // callback
    if(callback){
      callback(port, duration);
    }
  }
}


