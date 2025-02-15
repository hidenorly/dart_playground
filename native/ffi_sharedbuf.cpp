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

#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

#include <dart_api.h>
#include <dart_api_dl.h>


class SharedBuf
{
protected:
  int mProjectId;
  int mSize;
  int mShmId;
  void* mAttachedAddress;

public:
  SharedBuf(int projectId): mProjectId(projectId), mSize(0), mShmId(-1), mAttachedAddress(nullptr){
  }

  virtual ~SharedBuf(){
    close();
  }

  bool create(int nSize){
    if( -1 != mShmId ){
      // already created
      return false;
    }
    if( -1 != (mShmId = shmget(mProjectId, nSize, IPC_CREAT | 0666)) ){
      // success to create
      mSize = nSize;
    }
    return ( -1 != mShmId );
  }

  void* attach(bool isReadOnly = false){
    if( -1 != mShmId ){
      if(!mAttachedAddress){
        mAttachedAddress = shmat(mShmId, NULL, isReadOnly ? SHM_RDONLY : 0);
      }
      return mAttachedAddress;
    }
    return nullptr;
  }

  bool detach(void){
    if( (-1 != mShmId) && mAttachedAddress ){
      shmdt( mAttachedAddress );
      mAttachedAddress = nullptr;
    }
    return ( mAttachedAddress == nullptr );
  }

  static bool releaseSharedMemory(int shmId)
  {
    return shmctl( shmId, IPC_RMID, NULL ) != -1;
  }

  bool close(void){
    detach();
    if( -1 != mShmId ){
      int shmId = mShmId;
      mShmId = -1;
      return releaseSharedMemory(shmId);
    }
    return false;
  }

  static int getFreeProjectSlot(const std::string path="/tmp"){
    for(int i=0; i<=255; i++){ // project id range: 0-255
      key_t key = ftok(path.c_str(), i);
      if(key!=-1){
        // try to create shared memory
        int shmid = shmget(key, 1, IPC_CREAT | IPC_EXCL | 0666);
        if(shmid!=-1){
          releaseSharedMemory(shmid);
          return i;
        }
      }
    }
    return -1;
  }
};

// TODO: manage multiple shared buffer instances
static std::shared_ptr<SharedBuf> gBuf;


extern "C"
{
  DART_EXPORT intptr_t InitDartApiDL(void* data) { 
     return Dart_InitializeApiDL(data); 
  } 

  DART_EXPORT int shm_get_free_slot(void)
  {
    return SharedBuf::getFreeProjectSlot();
  }

  DART_EXPORT bool shm_create(int shmId, int nSize, bool isReadOnly)
  {
    std::cout << "shm_create::process id:" << std::dec << getpid() << " thread id:" << std::hex << std::this_thread::get_id() << std::endl;
    if(!gBuf){
      gBuf = std::make_shared<SharedBuf>(shmId);
      return gBuf->create(nSize) && (gBuf->attach(isReadOnly)!=nullptr);
    }
    return false;
  }

  DART_EXPORT bool shm_write(int shmId, char* data, int nSize)
  {
    if(gBuf){
      void* p = gBuf->attach();
      memcpy(p, data, nSize);
      return true;
    }
    return false;
  }

  DART_EXPORT char* shm_read(int shmId)
  {
    return gBuf ?  (char*)gBuf->attach() : nullptr;
  }

  DART_EXPORT bool shm_close(int shmId)
  {
    return gBuf ?  gBuf->close() : false;
  }
};
