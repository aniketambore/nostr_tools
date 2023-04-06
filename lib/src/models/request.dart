import 'dart:convert';

import 'package:nostr_tools/src/models/filter.dart';

class Request {
  /// subscription_id is a random string that should be used to represent a subscription.
  late String subscriptionId;

  /// A list of filters that determines which events will be sent in the subscription.
  late List<Filter> filters;

  Request(this.subscriptionId, this.filters);

  /// Serializes the Request instance into a Nostr message format.
  ///
  /// The Nostr message format is a JSON-encoded array with the following structure:
  /// ["REQ", subscription_id, filter JSON, filter JSON, ...]
  String serialize() {
    final theFilters =
        json.encode(filters.map((item) => item.toJson()).toList());
    final header = json.encode(['REQ', subscriptionId]);
    return '${header.substring(0, header.length - 1)},${theFilters.substring(1, theFilters.length)}';
  }

  /// Deserializes a Nostr message into a Request instance.
  ///
  /// The Nostr message format is a JSON-encoded array with the following structure:
  /// ["REQ", subscription_id, filter JSON, filter JSON, ...]
  Request.deserialize(input) {
    assert(input.length >= 3);
    subscriptionId = input[1];
    filters = [];
    for (var i = 2; i < input.length; i++) {
      filters.add(Filter.fromJson(input[i]));
    }
  }
}
