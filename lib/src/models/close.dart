import 'dart:convert';

/// Represents a 'CLOSE' message for closing a subscription.
class Close {
  /// The ID of the subscription to close.
  late String subscriptionId;

  /// Creates a [Close] instance with the given [subscriptionId].
  Close(this.subscriptionId);

  /// Encodes the 'CLOSE' message to a JSON-encoded string.
  String serialize() => jsonEncode(['CLOSE', subscriptionId]);

  /// Deserializes a JSON-encoded input string into a [Close] instance.
  ///
  /// Throws an [AssertionError] if the input length is not equal to 2.
  Close.deserialize(List<String> input) {
    assert(input.length == 2);
    subscriptionId = input[1];
  }
}
