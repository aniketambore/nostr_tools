library impl.event;

import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/models.dart';

import '../api/api.dart';
import '../utils/utils.dart';

class EventImpl implements EventApi {
  final _keyApi = KeyApi();
  @override
  String getEventHash(Event event) {
    final data = [
      0,
      event.pubkey,
      event.created_at,
      event.kind,
      event.tags,
      event.content,
    ];

    final serializedEvent = json.encode(data);
    List<int> eventHash = sha256.convert(utf8.encode(serializedEvent)).bytes;
    return HexUtil.encode(eventHash);
  }

  @override
  String signEvent(Event event, String privateKey) {
    String aux = HexUtil.generate64RandomHexChars();
    return Bip340Util.sign(privateKey, event.id, aux);
  }

  @override
  bool verifySignature(Event event) {
    return Bip340Util.verify(event.pubkey, event.id, event.sig);
  }

  @override
  Event finishEvent(Event event, String privateKey) {
    event.pubkey = _keyApi.getPublicKey(privateKey);
    event.id = getEventHash(event);
    event.sig = signEvent(event, privateKey);
    return event;
  }
}
