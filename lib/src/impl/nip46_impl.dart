library impl.nip46;

import 'dart:convert';
import 'dart:core';

import '../api/api.dart';

class Nip46Impl implements Nip46 {
  String? _relay;
  String? _target;
  String? _metadata;
  Map<String, dynamic>? _metadataMap;

  @override
  Map<String, dynamic> fromURI(String uri) {
    final url = Uri.parse(uri);
    _target = url.host;
    if (_target == null) throw UnimplementedError();

    _relay = url.queryParameters["relay"];
    if (_relay == null) throw UnimplementedError();

    _metadata = url.queryParameters["metadata"];
    if (_metadata == null) throw UnimplementedError();

    _metadataMap = jsonDecode(_metadata!);

    return {
      "target": _target,
      "relay": _relay,
      "metadata": _metadataMap,
    };
  }

  @override
  String toString() {
    return "nostrconnect://$_target?metadata=${Uri.encodeComponent(
      jsonEncode(_metadataMap)
    )}&relay=${Uri.encodeComponent(_relay!)}";
  }

  // TODO - figure out how to use the classes constructor to initialize
  @override
  Map<String, dynamic> init(Map<String, dynamic> uri) {
    _target = uri["target"] as String;
    _relay = uri["relay"] as String;
    _metadataMap = uri["metadata"] as Map<String, dynamic>;
    return {
      "target": _target,
      "relay": _relay,
      "metadata": _metadataMap,
    };
  }

  // @override
  // String connect(String hex) {
  //   return 'fromconnectURI return';
  // }
    // final String _target;
  // @override
  // String approve() {
  //   return 'nsec1';
  // }
  // @override
  // String reject() {
  //   return 'nsec1';
  // }
}
