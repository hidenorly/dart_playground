//
//  Generated code. Do not modify.
//  source: grpc_idl.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EmptyMessage extends $pb.GeneratedMessage {
  factory EmptyMessage() => create();
  EmptyMessage._() : super();
  factory EmptyMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EmptyMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmptyMessage', createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EmptyMessage clone() => EmptyMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EmptyMessage copyWith(void Function(EmptyMessage) updates) => super.copyWith((message) => updates(message as EmptyMessage)) as EmptyMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmptyMessage create() => EmptyMessage._();
  EmptyMessage createEmptyInstance() => create();
  static $pb.PbList<EmptyMessage> createRepeated() => $pb.PbList<EmptyMessage>();
  @$core.pragma('dart2js:noInline')
  static EmptyMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmptyMessage>(create);
  static EmptyMessage? _defaultInstance;
}

class MyRequest extends $pb.GeneratedMessage {
  factory MyRequest({
    $core.String? text,
  }) {
    final $result = create();
    if (text != null) {
      $result.text = text;
    }
    return $result;
  }
  MyRequest._() : super();
  factory MyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyRequest', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyRequest clone() => MyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyRequest copyWith(void Function(MyRequest) updates) => super.copyWith((message) => updates(message as MyRequest)) as MyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyRequest create() => MyRequest._();
  MyRequest createEmptyInstance() => create();
  static $pb.PbList<MyRequest> createRepeated() => $pb.PbList<MyRequest>();
  @$core.pragma('dart2js:noInline')
  static MyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyRequest>(create);
  static MyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);
}

class MyResponse extends $pb.GeneratedMessage {
  factory MyResponse({
    $core.String? receivedText,
  }) {
    final $result = create();
    if (receivedText != null) {
      $result.receivedText = receivedText;
    }
    return $result;
  }
  MyResponse._() : super();
  factory MyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MyResponse', createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'receivedText')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MyResponse clone() => MyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MyResponse copyWith(void Function(MyResponse) updates) => super.copyWith((message) => updates(message as MyResponse)) as MyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MyResponse create() => MyResponse._();
  MyResponse createEmptyInstance() => create();
  static $pb.PbList<MyResponse> createRepeated() => $pb.PbList<MyResponse>();
  @$core.pragma('dart2js:noInline')
  static MyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MyResponse>(create);
  static MyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get receivedText => $_getSZ(0);
  @$pb.TagNumber(1)
  set receivedText($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReceivedText() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceivedText() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
