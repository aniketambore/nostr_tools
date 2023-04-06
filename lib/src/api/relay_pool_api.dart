/// This library provides an API for interacting with a pool of relays.
library api.relay_pool;

import '../models/models.dart';
import '../impl/impl.dart';

/// An abstract class representing the RelayPool API.
///
/// This API enables interaction with a pool of relays, and provides methods
/// for connecting to relays, subscribing to filters, publishing events, and
/// monitoring the status of the connected relays.
abstract class RelayPoolApi {
  /// Creates a new RelayPool instance with the specified list of relay URLs.
  factory RelayPoolApi({required List<String> relaysList}) =>
      RelayPool(relays: relaysList);

  /// Establishes a connection to the relays in the pool and returns a stream
  /// of messages received from the connected relays.
  Future<Stream<Message>> connect();

  /// Registers a callback function to be invoked when relay events occur.
  void on(Function(RelayEvent) callback);

  /// Closes the connection to the relays in the pool.
  void close();

  /// Subscribes to a set of filters to receive events that match the specified
  /// criteria from the connected relays.
  void sub(List<Filter> filters);

  /// Publishes an event to the connected relays.
  void publish(Event event);

  /// Returns a set of URLs for relays that are currently connected.
  Set<String> get connectedRelays;

  /// Returns a set of URLs for relays that failed to connect.
  Set<String> get failedRelays;
}
