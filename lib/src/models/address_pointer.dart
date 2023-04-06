/// A pointer to a Nostr address.
///
/// The [AddressPointer] class is used to store information about a Nostr address
/// including an identifier, a public key, a kind, and a list of relays.
class AddressPointer {
  /// The identifier for the address.
  final String identifier;

  /// The public key associated with the address.
  final String pubkey;

  /// The kind of the address.
  final int kind;

  /// The list of relays associated with the address.
  final List<String>? relays;

  /// Creates a new [AddressPointer] instance.
  ///
  /// The [identifier], [pubkey], and [kind] parameters are required.
  /// The [relays] parameter is optional and can be `null`.
  AddressPointer({
    required this.identifier,
    required this.pubkey,
    required this.kind,
    this.relays,
  });
}
