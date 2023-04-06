/// This library provides an API to interact with a relay service that supports
/// broadcasting and receiving Nostr events. It abstracts away the implementation
/// details of the underlying WebSocket connection and provides a higher-level API
/// for subscribing to and publishing events.
library api.relay;

import '../models/models.dart';
import '../impl/impl.dart';

/// An abstract class that defines the API for interacting with a relay service.
abstract class RelayApi {
  /// Creates a new instance of [RelayApi] with the specified `relayUrl`.
  factory RelayApi({required String relayUrl}) => Relay(relayUrl: relayUrl);

  /// The URL of the relay to connect to.
  late final String relayUrl;

  /// Connects to the relay server and returns a stream of [Message] objects.
  Future<Stream<Message>> connect();

  /// Sets a callback function to be called when events occur on the relay.
  /// The `callback` function should take a single argument of type [RelayEvent].
  void on(Function(RelayEvent) callback);

  /// Closes the WebSocket connection to the relay.
  void close();

  /// Subscribes to a set of filters on the relay. Only events that match the filters
  /// will be received. The `filters` argument is a list of [Filter] objects.
  void sub(List<Filter> filters);

  /// Publishes an event to the relay.
  void publish(Event event);
}
