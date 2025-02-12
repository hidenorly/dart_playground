# README

This is dart playground.



## FFITest

For MacOS

```
clang -c -o dart_api_dl.o -fPIC -I/Users/harold/flutter/flutter/bin/cache/dart-sdk/include /Users/harold/flutter/flutter/bin/cache/dart-sdk/include/dart_api_dl.c

clang++ -shared -o libffitest.dylib -fPIC -std=c++20 \
    -I/Users/harold/flutter/flutter/bin/cache/dart-sdk/include \
    dart_api_dl.o native/ffi_test.cpp

dart bin/ffi_test.dart                                
native_port=8236701556897007
Initializing...
Initialized:ok
FFIThreadTest::execute
Dart_CObject
Dart_PostCObject_DL
FFIThreadTest::execute::bail
Dart: received message: 2530
```


### Supplemental info.

```
nm dart_api_dl.o| grep Dart
0000000000000930 S _Dart_CloseNativePort_DL
00000000000009e8 S _Dart_CurrentIsolate_DL
00000000000009e0 S _Dart_DeleteFinalizableHandle_DL
00000000000009c0 S _Dart_DeletePersistentHandle_DL
00000000000009d0 S _Dart_DeleteWeakPersistentHandle_DL
00000000000009f8 S _Dart_EnterIsolate_DL
0000000000000a28 S _Dart_EnterScope_DL
0000000000000970 S _Dart_ErrorGetException_DL
0000000000000978 S _Dart_ErrorGetStackTrace_DL
0000000000000968 S _Dart_ErrorHasException_DL
00000000000009f0 S _Dart_ExitIsolate_DL
0000000000000a30 S _Dart_ExitScope_DL
0000000000000960 S _Dart_GetError_DL
00000000000009a0 S _Dart_HandleFromPersistent_DL
00000000000009a8 S _Dart_HandleFromWeakPersistent_DL
00000000000000e4 T _Dart_InitializeApiDL
0000000000000940 S _Dart_IsApiError_DL
0000000000000950 S _Dart_IsCompilationError_DL
0000000000000938 S _Dart_IsError_DL
0000000000000958 S _Dart_IsFatalError_DL
0000000000000a38 S _Dart_IsNull_DL
0000000000000948 S _Dart_IsUnhandledExceptionError_DL
0000000000000980 S _Dart_NewApiError_DL
0000000000000988 S _Dart_NewCompilationError_DL
00000000000009d8 S _Dart_NewFinalizableHandle_DL
0000000000000928 S _Dart_NewNativePort_DL
00000000000009b0 S _Dart_NewPersistentHandle_DL
0000000000000a10 S _Dart_NewSendPortEx_DL
0000000000000a08 S _Dart_NewSendPort_DL
0000000000000990 S _Dart_NewUnhandledExceptionError_DL
00000000000009c8 S _Dart_NewWeakPersistentHandle_DL
0000000000000a40 S _Dart_Null_DL
0000000000000918 S _Dart_PostCObject_DL
0000000000000920 S _Dart_PostInteger_DL
0000000000000a00 S _Dart_Post_DL
0000000000000998 S _Dart_PropagateError_DL
0000000000000a20 S _Dart_SendPortGetIdEx_DL
0000000000000a18 S _Dart_SendPortGetId_DL
00000000000009b8 S _Dart_SetPersistentHandle_DL
0000000000000a48 S _Dart_UpdateExternalSize_DL
0000000000000088 T _Dart_UpdateExternalSize_Deprecated
0000000000000a50 S _Dart_UpdateFinalizableExternalSize_DL
00000000000000b4 T _Dart_UpdateFinalizableExternalSize_Deprecated
```
