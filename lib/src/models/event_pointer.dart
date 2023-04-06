/// EventPointer is a class that represents a pointer to an event in the Nostr protocol.
class EventPointer {
  /// The unique identifier of the event.
  final String id;

  /// A list of relays to use to reach the event.
  final List<String>? relays;

  /// The author of the event.
  final String? author;

  /// Constructs an EventPointer object with the given properties.
  ///
  /// The [id] parameter is required and represents the unique identifier of the event.
  /// The [relays] parameter is optional and represents a list of relays to use to reach the event.
  /// The [author] parameter is optional and represents the author of the event.
  EventPointer({required this.id, this.relays, this.author});
}
