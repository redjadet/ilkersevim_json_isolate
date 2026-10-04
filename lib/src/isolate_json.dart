import 'dart:convert';

import 'package:flutter/foundation.dart';

const int _kIsolateDecodeThreshold = 8 * 1024;
const int _kIsolateEncodeSmallCollectionMax = 20;

/// Decodes UTF-8 bytes to JSON using `utf8.decoder` fused with `json.decoder`
/// (avoids materializing the full JSON as a Dart [String] before parsing).
/// Prefer [decodeJsonMapFromBytes] when the HTTP stack exposes raw bytes
/// (for example Dio `ResponseType.bytes`) — same isolate threshold as the
/// string APIs.
final Converter<List<int>, Object?> _kUtf8JsonConverter = utf8.decoder.fuse(
  json.decoder,
);

Uint8List _bytesToUint8List(List<int> bytes) =>
    bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

Object? _decodeJsonUtf8BytesForIsolate(Uint8List bytes) =>
    _kUtf8JsonConverter.convert(bytes);

Future<Map<String, dynamic>> decodeJsonMap(String payload) async {
  if (payload.length < _kIsolateDecodeThreshold) {
    final dynamic decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON object');
  }

  final dynamic decoded = await compute(_decodeJson, payload);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON object');
}

Future<List<dynamic>> decodeJsonList(String payload) async {
  if (payload.length < _kIsolateDecodeThreshold) {
    final dynamic decoded = jsonDecode(payload);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON array');
  }

  final dynamic decoded = await compute(_decodeJson, payload);
  if (decoded is List<dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON array');
}

dynamic _decodeJson(String payload) => jsonDecode(payload);

Future<Map<String, dynamic>> decodeJsonMapFromBytes(List<int> bytes) async {
  final Uint8List utf8Bytes = _bytesToUint8List(bytes);
  if (utf8Bytes.lengthInBytes < _kIsolateDecodeThreshold) {
    return _decodeJsonMapFromUtf8Sync(utf8Bytes);
  }
  final Object? decoded = await compute(
    _decodeJsonUtf8BytesForIsolate,
    utf8Bytes,
  );
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON object');
}

Future<List<dynamic>> decodeJsonListFromBytes(List<int> bytes) async {
  final Uint8List utf8Bytes = _bytesToUint8List(bytes);
  if (utf8Bytes.lengthInBytes < _kIsolateDecodeThreshold) {
    return _decodeJsonListFromUtf8Sync(utf8Bytes);
  }
  final Object? decoded = await compute(
    _decodeJsonUtf8BytesForIsolate,
    utf8Bytes,
  );
  if (decoded is List<dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON array');
}

Map<String, dynamic> _decodeJsonMapFromUtf8Sync(Uint8List utf8Bytes) {
  final Object? decoded = _kUtf8JsonConverter.convert(utf8Bytes);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON object');
}

List<dynamic> _decodeJsonListFromUtf8Sync(Uint8List utf8Bytes) {
  final Object? decoded = _kUtf8JsonConverter.convert(utf8Bytes);
  if (decoded is List<dynamic>) {
    return decoded;
  }
  throw const FormatException('Expected a JSON array');
}

/// Encodes a JSON-serializable object to a JSON string, optionally in an
/// isolate when the payload is large enough to justify isolate overhead.
///
/// - [String]: encoded on the current isolate when shorter than 8 KiB;
///   otherwise via `compute()`.
/// - [List] and [Map]: encoded on the current isolate when they have fewer
///   than 20 elements; otherwise via `compute()`.
/// - Other JSON-serializable values: always encoded via `compute()`.
///
/// This is useful for size estimation operations that don't need the result
/// immediately, such as cache size calculations.
Future<String> encodeJsonIsolate(dynamic object) async {
  if (object is String) {
    if (object.length < _kIsolateDecodeThreshold) {
      return jsonEncode(object);
    }
    return compute(_encodeJson, object);
  }

  if (object is List<dynamic>) {
    if (object.length < _kIsolateEncodeSmallCollectionMax) {
      return jsonEncode(object);
    }
  }

  if (object is Map<dynamic, dynamic>) {
    if (object.length < _kIsolateEncodeSmallCollectionMax) {
      return jsonEncode(object);
    }
  }

  return compute(_encodeJson, object);
}

String _encodeJson(dynamic object) => jsonEncode(object);
