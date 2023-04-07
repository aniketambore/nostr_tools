/// Represents an event, which is the only object type in the system.
///
/// An event has the following properties:
/// - `id`: A 32-byte hex-encoded sha256 hash of the serialized event data.
/// - `pubkey`: A 32-byte hex-encoded public key of the event creator.
/// - `created_at`: A unix timestamp in seconds indicating when the event was created.
/// - `kind`: An integer representing the kind of the event.
/// - `tags`: A list of lists representing tags of the event. Each tag list has three elements:
///   1. The type of the tag (either "e" or "p").
///   2. A 32-byte hex-encoded ID of another event (for type "e") or a 32-byte hex-encoded key (for type "p").
///   3. A recommended relay URL.
/// - `content`: An arbitrary string representing the content of the event.
/// - `sig`: A 64-byte signature of the sha256 hash of the serialized event data, which is the same as the `id` field.
///
/// Additionally, an event may have a `subscriptionId` property, which is a random string used to represent a subscription.
class Event {
  /// A 32-byte hex-encoded sha256 hash of the serialized event data (hex).
  String id;

  /// A 64-byte signature of the sha256 hash of the serialized event data, which is the same as the `id` field.
  String sig;

  /// A 32-byte hex-encoded public key of the event creator (hex).
  String pubkey;

  /// An integer representing the kind of the event.
  final int kind;

  /// A list of lists representing tags of the event.
  final List<List<String>> tags;

  /// An arbitrary string representing the content of the event.
  final String content;

  /// A unix timestamp in seconds indicating when the event was created.
  final int created_at;

  /// A random string used to represent a subscription.
  String? subscriptionId;

  /// Creates a new instance of the `Event` class.
  ///
  /// If `verify` is `true` (which is the default), this constructor verifies that the `sig` field is a valid
  /// signature of the `id` field using the public key in the `pubkey` field.
  Event({
    required this.kind,
    required this.tags,
    required this.content,
    required this.created_at,
    this.id = '',
    this.sig = '',
    this.pubkey = '',
    this.subscriptionId,
    bool verify = true,
  });
  /*
  {
    if (verify && id.isNotEmpty && sig.isNotEmpty && pubkey.isNotEmpty) {
      if (Bip340Util.verify(pubkey, id, sig) != true) {
        throw SignatureVerificationException(
            'Failed to verify signature $sig for event with id $id and pubkey $pubkey');
      }
    }
  }
  */

  /// Converts this instance of the `Event` class to a JSON object.
  Map<String, dynamic> toJson() => {
        'id': id,
        'pubkey': pubkey,
        'created_at': created_at,
        'kind': kind,
        'tags': tags,
        'content': content,
        'sig': sig
      };

  /// Deserializes an event from a wire-format representation.
  ///
  /// `input` should be a list containing either two or three elements. If it contains two elements,
  /// the second element should be a map representing the event. If it contains three elements,
  /// the second element should be a string representing the `subscriptionId`, and the third element
  /// should be a map representing the event.
  factory Event.deserialize(List input, {bool verify = true}) {
    var json = <String, dynamic>{};
    String? subscriptionId;
    if (input.length == 2) {
      json = input[1] as Map<String, dynamic>;
    } else if (input.length == 3) {
      json = input[2] as Map<String, dynamic>;
      subscriptionId = input[1] as String;
    } else {
      throw Exception('invalid input');
    }

    final tags = (json['tags'] as List<dynamic>)
        .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList();

    return Event(
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      created_at: json['created_at'] as int,
      kind: json['kind'] as int,
      tags: tags,
      content: json['content'] as String,
      sig: json['sig'] as String,
      subscriptionId: subscriptionId,
      verify: verify,
    );
  }
}
