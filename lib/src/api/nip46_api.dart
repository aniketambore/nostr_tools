/// This library provides the interface for NIP-46.
library api.nip46;

import 'dart:async';
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

  Future<void> approve(String secretKey) async {
    final pubkey = keyApi.getPublicKey(secretKey);
    final rpc = NostrRPCApi(relay: this.relay, secretKey: secretKey, pubkey: pubkey);
    await rpc.call(
      target,
      {
        'method': 'connect',
        'params': [pubkey],
      },
      skipResponse: true,
    );
  }

  Future<void> reject(String secretKey) async {
    final pubkey = keyApi.getPublicKey(secretKey);
    final rpc = NostrRPCApi(relay: this.relay, secretKey: secretKey, pubkey: pubkey);
    await rpc.call(
      target,
      {
        'method': 'disconnect',
        'params': [],
      },
      skipResponse: true,
    );
  }
}

class Connect {
  late NostrRPCApi rpc;
  late Stream<Event> events;
  final KeyApi keyApi = KeyApi();
  String? target;

  Connect({
    required target,
    required relay,
    required secretKey
  }) {
    final controller = StreamController<Event>();
    events = controller.stream;
    rpc = NostrRPCApi(relay: relay, secretKey: secretKey, pubkey: keyApi.getPublicKey(secretKey));
    if (target) {
      this.target = target;
    }
  }

  Future<void> init() async {
    await rpc.listen();
    sub.on('event', (Event event) async {
      try {
        final plaintext = await nip04.decrypt(
          rpc.self.secret!,
          event.pubkey,
          event.content,
        );
        if (plaintext == null) throw Error();
        final payload = jsonDecode(plaintext);
        if (!isValidRequest(payload)) return;

        switch (payload['method']) {
          case 'connect':
            {
              if (payload['params'] == null || payload['params'].length != 1) {
                throw Error();
              }
              final pubkey = payload['params'][0];
              target = pubkey;
              events.emit('connect', [pubkey]);
              break;
            }
          case 'disconnect':
            {
              target = null;
              events.emit('disconnect', []);
              break;
            }
          default:
            {}
        }
      } catch (ignore) {
        return;
      }
    });
  }

  void on(String evt, Function cb) {
    events.on(evt, cb);
  }

  void off(String evt, Function cb) {
    events.off(evt, cb);
  }
  Future<void> disconnect() async {
    if (target == null) {
      throw Error();
    }
    events.emit('disconnect', []);
    try {
      await rpc.call(
        {
          'target': target!,
          'request': {
            'method': 'disconnect',
            'params': [],
          },
        },
        skipResponse: true,
      );
    } catch (error) {
      throw Error();
    }
    target = null;
  }

  Future<String> getPublicKey() async {
    if (target == null) {
      throw Error();
    }
    final response = await rpc.call({
      'target': target!,
      'request': {
        'method': 'get_public_key',
        'params': [],
      },
    });
    return response as String;
  }

  Future<Event> signEvent(Map<String, dynamic> event) async {
    if (target == null) {
      throw Error();
    }
    final eventWithSig = await rpc.call({
      'target': target!,
      'request': {
        'method': 'sign_event',
        'params': [event],
      },
    });
    return eventWithSig as Event;
  }
}