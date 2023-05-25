library api.relay;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import '../../nostr_tools.dart';
import '../models/models.dart';
import '../impl/impl.dart';

final nip04 = Nip04();
final keyApi = KeyApi();
final eventApi = EventApi();

Future<Event> prepareEvent(String secretKey, String pubkey, String content) async {
  final cipherText = nip04.encrypt(secretKey, pubkey, content);

  final event = Event(
    kind: 24133,
    created_at: DateTime.now().millisecondsSinceEpoch,
    pubkey: keyApi.getPublicKey(secretKey),
    tags: [['p', pubkey]],
    content: cipherText,
    id: '',
    sig: '',
  );

  final signedEvent = eventApi.finishEvent(event, secretKey);
  final ok = eventApi.verifySignature(signedEvent);
  if (!ok) {
    throw Exception('Event is not valid');
  }

  return signedEvent;
}

String randomID() {
  return Random().nextInt(9007199254740992).toString();
}

class RPCRequest {
  String? method;
  List<String>? params;
  // ID is optional, the others are required
  String? id;
}

bool containsTag(List<List<String>> tags, String tagType) {
  for (int i = 0; i < tags.length; i++) {
    for (int j = 0; j < tags[i].length; j++) {
      if (tags[i][j] == tagType) {
        return true;
      }
    }
  }
  return false;
}

bool isValidResponse(dynamic payload) {
  if (payload == null) return false;

  final keys = payload.keys.toList();
  if (!keys.contains('id') ||
      !keys.contains('result') ||
      !keys.contains('error')) {
    return false;
  }

  return true;
}

class NostrRPCApi {
  final String relay;
  final String pubkey;
  final String secretKey;
  Event? event;

  NostrRPCApi({
    required this.relay,
    required this.pubkey,
    required this.secretKey
  });

  Future<dynamic> call (
    String target,
    Map<String, dynamic> request,
    {
      bool? skipResponse,
      num? timeout,
    }
  ) async {
    final relay = RelayApi(relayUrl: this.relay);
    final stream = await relay.connect();
    final reqId = request['id'] ?? randomID();
    final preppedRequest = jsonEncode({
      'id': reqId,
      'method': request['method'],
      'params': request['params'],
    });
    final preppedEvent = await prepareEvent(secretKey, pubkey, preppedRequest);

    final filter = Filter(
      kinds: [24133],
      authors: [target],
      p: [pubkey],
      limit: 1,
    );

    await Future<void>(() async {
      relay.sub([filter]);
      relay.publish(preppedEvent);

      // skip waiting for response from remote
      if (skipResponse == true) {
        return;
      }

      // watch relayStream messages
      stream.listen((Message message) async {
        if (message.type == 'EVENT') {
          Event event = message.message;
          if (event.kind != 24133) return;
          if (event.pubkey != target) return;
          if (!containsTag(event.tags, "p")) return;
          try {
            final plaintext = nip04.decrypt(
              secretKey,
              pubkey,
              event.content,
            );
            if (plaintext.isEmpty) throw Exception('failed to decrypt event');
            final payload = jsonDecode(plaintext);
            // ignore all the events that are not NostrRPCResponse events
            if (!isValidResponse(payload)) return;

            // ignore all the events that are not for this request
            if (payload['id'] != reqId) return;

            // if the response is an error, reject the promise
            if (payload['error'] != null) {
              throw Exception(payload['error']);
            }

            // if the response is a result, resolve the promise
            if (payload['result'] != null) {
              return payload['result'];
            }
          } catch (e) {
            throw Exception(e);
          }
        }
      });
    });
  }

  Future<void> listen() async {
    final relay = RelayApi(relayUrl: this.relay);
    final stream = await relay.connect();

    final filter = Filter(
      kinds: [24133],
      p: [pubkey],
      since: DateTime.now().millisecondsSinceEpoch,
    );
    final sub = relay.sub([filter]);

    // watch relayStream messages
    stream.listen((Message message) async {
      Event event = message.message;
      if (event.kind != 24133) return;
      if (!containsTag(event.tags, "p")) return;

      try {
        final plaintext = nip04.decrypt(
          secretKey,
          event.pubkey,
          event.content,
        );
        if (plaintext.isEmpty) throw new Exception('failed to decrypt event');
        final payload = jsonDecode(plaintext);
        // ignore all the events that are not NostrRPCResponse events
        if (!isValidResponse(payload)) return;

        // handle request
        if (payload.method == "get_public_key") {
          final response = await handleRequest(payload, event);

          final body = prepareResponse(
            response.id,
            response.result,
            response.error,
          );

          final responseEvent = await prepareEvent(
            this.self.secret,
            event.pubkey,
            body,
          );

          // send response via relay
          relay.publish(responseEvent);
        } else {
          throw Exception('Method not yet implemented');
        }
      } catch (e) {
        throw Exception(e);
      }

    });

    return sub;
  }

  dynamic handleRequest(Map<String, dynamic> payload, Event event) async {
    final method = payload['method'];
    final params = payload['params'];

    switch (method) {
      case 'get_public_key':
        return this.getPublicKey(params);
      case 'sign_event':
        return this.getPublicKey(params);
      default:
        throw Exception('Method not yet implemented');
    }
  }

  Future<String> getPublicKey(List<String> params) async {
    final target = params[0];
    final key = await keyApi.getPublicKey(target);
    return key;
  }

  Future<String> signEvent(List<String> params) async {
    final target = params[0];
    final event = params[1];
    final key = await keyApi.getPublicKey(target);
    final signedEvent = await prepareEvent(
      this.self.secret,
      key,
      event,
    );
    return signedEvent;
  }
}
