//
//  Generated code. Do not modify.
//  source: grpc_idl.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyMessageDescriptor instead')
const EmptyMessage$json = {
  '1': 'EmptyMessage',
};

/// Descriptor for `EmptyMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyMessageDescriptor = $convert.base64Decode(
    'CgxFbXB0eU1lc3NhZ2U=');

@$core.Deprecated('Use myRequestDescriptor instead')
const MyRequest$json = {
  '1': 'MyRequest',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `MyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myRequestDescriptor = $convert.base64Decode(
    'CglNeVJlcXVlc3QSEgoEdGV4dBgBIAEoCVIEdGV4dA==');

@$core.Deprecated('Use myResponseDescriptor instead')
const MyResponse$json = {
  '1': 'MyResponse',
  '2': [
    {'1': 'received_text', '3': 1, '4': 1, '5': 9, '10': 'receivedText'},
  ],
};

/// Descriptor for `MyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List myResponseDescriptor = $convert.base64Decode(
    'CgpNeVJlc3BvbnNlEiMKDXJlY2VpdmVkX3RleHQYASABKAlSDHJlY2VpdmVkVGV4dA==');

