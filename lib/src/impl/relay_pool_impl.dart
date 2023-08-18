library impl.relay_pool;

import 'dart:async';
import 'dart:convert';

import 'package:nostr_tools/src/api/api.dart';
import 'package:nostr_tools/src/models/models.dart';
import 'package:nostr_tools/src/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RelayPool implements RelayPoolApi {
  final List<String> relays;

  late List<WebSocketChannel> _channels;
  void Function(RelayEvent)? onEvent;

  final Set<String> _connectedRelays = {};
  final Set<String> _failedRelays = {};
  final Set<String> _receivedMessageIds = {};

  RelayPool({required this.relays});

  @override
  Future<Stream<Message>> connect() async {
    _channels = [];
    final controller = StreamController<Message>();

    for (final relayUrl in relays) {
      try {
        final channel = WebSocketChannel.connect(Uri.parse(relayUrl));
        _channels.add(channel);
        channel.stream.listen(
          (event) {
            Message message = Message.deserialize(event as String);

            String? id = message.message is Event ? message.message.id : null;
            if (!_connectedRelays.contains(relayUrl)) {
              _connectedRelays.add(relayUrl);
              _failedRelays.remove(
                relayUrl,
              ); // remove from failed relays set if previously failed
              onEvent?.call(RelayEvent.connect);
            }
            if (id != null && !_receivedMessageIds.contains(id)) {
              _receivedMessageIds.add(id);
              controller.add(message);
            }
          },
          onError: (error, stackTrace) {
            final errorMsg =
                '[!] WebSocketChannel onError: $error\n$stackTrace';
            if (!_connectedRelays.contains(relayUrl)) {
              _failedRelays.add(relayUrl);
              onEvent?.call(RelayEvent.connect);
            } else {
              controller.addError(errorMsg, stackTrace);
            }
          },
          onDone: () {
            if (_channels.every((c) => c.closeCode != null)) {
              final error =
                  '[!] All WebSockets closed with code ${_channels.map((c) => c.closeCode).toList()}';
              controller.addError(error);
            }
            if (_channels.every((c) => c.closeCode != null)) {
              controller.close();
              close();
            }
          },
        );
      } catch (e) {
        _failedRelays.add(relayUrl);
        final errorMsg = '[!] Failed to connect to relay at $relayUrl\n$e';
        onEvent?.call(RelayEvent.error);
        if (_failedRelays.length == relays.length) {
          controller.addError(errorMsg);
        }
      }
    }
    return controller.stream;
  }

  @override
  void on(void Function(RelayEvent p1) callback) {
    onEvent = callback;
  }

  @override
  void close() {
    for (final channel in _channels) {
      channel.sink.close();
    }
    _connectedRelays.clear();
    _failedRelays.clear();
    _receivedMessageIds.clear();
  }

  @override
  void sub(List<Filter> filters) {
    for (final channel in _channels) {
      final message = Request(HexUtil.generate64RandomHexChars(), filters);
      channel.sink.add(message.serialize());
    }
  }

  @override
  void publish(Event event) {
    final serializedEvent = json.encode(['EVENT', event.toJson()]);
    for (final channel in _channels) {
      channel.sink.add(serializedEvent);
    }
  }

  @override
  Set<String> get connectedRelays => _connectedRelays;

  @override
  Set<String> get failedRelays => _failedRelays;
}
