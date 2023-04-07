library impl.relay;

import 'dart:async';
import 'dart:convert';

import 'package:nostr_tools/src/api/api.dart';
import 'package:nostr_tools/src/models/models.dart';
import 'package:nostr_tools/src/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Relay implements RelayApi {
  @override
  final String relayUrl;

  late WebSocketChannel _channel;
  void Function(RelayEvent)? onEvent;
  bool _connected = false;

  Relay({required this.relayUrl});

  @override
  set relayUrl(String newRelayUrl) {
    _connected = false;
    relayUrl = newRelayUrl;
  }

  // Connect to the relay server and return a Stream of messages
  @override
  Future<Stream<Message>> connect() async {
    // Establish a WebSocket channel with the relay server
    _channel = WebSocketChannel.connect(Uri.parse(relayUrl));

    // Create a new stream controller to manage the stream of messages
    final controller = StreamController<Message>();

    // Listen to the stream of events from the WebSocket channel
    _channel.stream.listen(
      (event) {
        // Deserialize the event message and add it to the stream controller
        Message message;

        try {
          message = Message.deserialize(event as String);
        } catch (e) {
          if (e is SignatureVerificationException) {
            // If a SignatureVerificationException is caught, propagate it to the caller
            controller.addError(e);
            return;
          } else {
            // If some other exception is caught, rethrow it
            rethrow;
          }
        }

        if (!_connected) {
          // If this is the first event after connecting to the server, set the _connected flag to true and call the onEvent callback with the RelayEvent.connect event
          _connected = true;
          onEvent?.call(RelayEvent.connect);
        } else {
          // Otherwise, add the event message to the stream controller
          controller.add(message);
        }
      },
      onError: (error) {
        // If there is an error with the WebSocket channel, add the error to the stream controller
        // If this is the first error after connecting to the server, set the _connected flag to true and call the onEvent callback with the RelayEvent.error event
        if (!_connected) {
          _connected = true;
          onEvent?.call(RelayEvent.error);
        }
        controller.addError(error as Object);
      },
      onDone: () {
        // When the WebSocket channel is closed, check the close code
        // If the close code is not null, add an error message to the stream controller
        // Close the stream controller
        if (_channel.closeCode != null) {
          final error = '[!] WebSocket closed with code ${_channel.closeCode}';
          controller.addError(error);
        }
        controller.close();
        close();
      },
    );

    // Return the stream of messages
    return controller.stream;
  }

  // Set the onEvent callback function to handle RelayEvents
  @override
  void on(void Function(RelayEvent p1) callback) {
    onEvent = callback;
  }

  // Close the WebSocket channel
  @override
  void close() {
    if (!_connected) return;
    _connected = false;
    _channel.sink.close();
  }

  // Subscribe to the relay server with the specified filters
  @override
  void sub(List<Filter> filters) {
    final message = Request(HexUtil.generate64RandomHexChars(), filters);
    _channel.sink.add(message.serialize());
  }

  // Publish an event to the relay server
  @override
  void publish(Event event) {
    final serializedEvent = json.encode(['EVENT', event.toJson()]);
    _channel.sink.add(serializedEvent);
  }
}
