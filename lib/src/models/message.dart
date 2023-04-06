import 'dart:convert';
import 'package:nostr_tools/src/models/close.dart';
import 'package:nostr_tools/src/models/event.dart';
import 'package:nostr_tools/src/models/request.dart';

class Message {
  late String type;
  late dynamic message;

  Message.deserialize(String payload) {
    dynamic data = json.decode(payload);
    final messages = ['EVENT', 'REQ', 'CLOSE', 'NOTICE', 'EOSE', 'OK', 'AUTH'];
    assert(messages.contains(data[0]), 'Unsupported payload (or NIP)');

    type = data[0] as String;
    switch (type) {
      case 'EVENT':
        message = Event.deserialize(data);
        break;
      case 'REQ':
        message = Request.deserialize(data);
        break;
      case 'CLOSE':
        message = Close.deserialize(data);
        break;
      default:
        message = jsonEncode(data.sublist(1));
        break;
    }
  }
}
