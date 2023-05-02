/// This library provides the interface for NIP-46.
library api.nip46;

import 'dart:convert';
import 'dart:core';

import '../../nostr_tools.dart';

class Nip46 {
  final String relay;
  final String target;
  final Map<String, dynamic> metaData;

  Nip46({
    required this.relay,
    required this.target,
    required this.metaData
  });
  Nip46 fromURI(String uri) {
    final url = Uri.parse(uri);
    final target = url.host;
    if (target == null) throw UnimplementedError();

    final relay = url.queryParameters["relay"];
    if (relay == null) throw UnimplementedError();

    final metadata = url.queryParameters["metadata"];
    if (metadata == null) throw UnimplementedError();

    final metadataMap = jsonDecode(metadata);

    return Nip46(relay: relay, target: target, metaData: metadataMap);
  }

  @override
  String toString() {
    return "nostrconnect://$target?metadata=${Uri.encodeComponent(
      jsonEncode(metaData)
    )}&relay=${Uri.encodeComponent(relay)}";
  }

  String connect(
    String secretKey,
    [String? relay]
  ) {
    final keyApi = KeyApi();
    final nostrRPC = NostrRPCApi(relay: relay ?? this.relay, pubkey: keyApi.getPublicKey(secretKey), secretKey: secretKey);

    return "connect return string";
  }
}