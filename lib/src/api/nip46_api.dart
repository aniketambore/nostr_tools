/// This library provides the interface for NIP-46.
library api.nip46;

import '../impl/impl.dart';

/// The abstract class [Nip46] is the public API for nostr-connect apps and signers.
abstract class Nip46 {
  /// Creates a [Nip46Impl] instance.
  factory Nip46() => Nip46Impl();

  Map<String, dynamic> fromURI(String uri);
  Map<String, dynamic> init(Map<String, dynamic> uri);

  // String connect(String hex);
  // String approve();
  // String reject();
  // String disconnect() {
  //   return "disconnect";
  // }
  // String getPublicKey() {
  //   return "public key";
  // }
  // String signEvent() {
  //   return "signing";
  // }
  // String describe() {
  //   throw UnimplementedError();
  // }
  // String delegate() {
  //   throw UnimplementedError();
  // }
  // Future<List<String>> getRelays() {
  //   throw UnimplementedError();
  // }
}