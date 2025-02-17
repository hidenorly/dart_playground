//
//  Generated code. Do not modify.
//  source: grpc_idl.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'grpc_idl.pb.dart' as $0;

export 'grpc_idl.pb.dart';

@$pb.GrpcServiceName('MyService')
class MyServiceClient extends $grpc.Client {
  static final _$method1 = $grpc.ClientMethod<$0.MyRequest, $0.MyResponse>(
      '/MyService/method1',
      ($0.MyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MyResponse.fromBuffer(value));
  static final _$shutdown = $grpc.ClientMethod<$0.EmptyMessage, $0.EmptyMessage>(
      '/MyService/shutdown',
      ($0.EmptyMessage value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.EmptyMessage.fromBuffer(value));

  MyServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.MyResponse> method1($0.MyRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$method1, request, options: options);
  }

  $grpc.ResponseFuture<$0.EmptyMessage> shutdown($0.EmptyMessage request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$shutdown, request, options: options);
  }
}

@$pb.GrpcServiceName('MyService')
abstract class MyServiceBase extends $grpc.Service {
  $core.String get $name => 'MyService';

  MyServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.MyRequest, $0.MyResponse>(
        'method1',
        method1_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MyRequest.fromBuffer(value),
        ($0.MyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EmptyMessage, $0.EmptyMessage>(
        'shutdown',
        shutdown_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EmptyMessage.fromBuffer(value),
        ($0.EmptyMessage value) => value.writeToBuffer()));
  }

  $async.Future<$0.MyResponse> method1_Pre($grpc.ServiceCall call, $async.Future<$0.MyRequest> request) async {
    return method1(call, await request);
  }

  $async.Future<$0.EmptyMessage> shutdown_Pre($grpc.ServiceCall call, $async.Future<$0.EmptyMessage> request) async {
    return shutdown(call, await request);
  }

  $async.Future<$0.MyResponse> method1($grpc.ServiceCall call, $0.MyRequest request);
  $async.Future<$0.EmptyMessage> shutdown($grpc.ServiceCall call, $0.EmptyMessage request);
}
