/// A library for generating private and public keys.
///
/// To generate a private key and its corresponding public key, create an instance
/// of [KeyApi] using its default constructor, and then call the methods
/// [generatePrivateKey()] and [getPublicKey()]. For example:
///
/// ```dart
/// import 'package:nostr_tools/api/keys.dart';
///
/// void main() {
///   final keyGenerator = KeyApi();
///
///   final privateKey = keyGenerator.generatePrivateKey();
///   print('[+] privateKey: $privateKey');
///
///   final publicKey = keyGenerator.getPublicKey(privateKey);
///   print('[+] publicKey: $publicKey');
/// }
/// ```
library api.keys;

import '../impl/impl.dart';

/// An abstract class representing a key generator.
abstract class KeyApi {
  /// Constructs a [KeyApi] instance.
  ///
  /// By default, this constructor returns a [KeyImpl] instance, which
  /// implements the [KeyApi] interface.
  factory KeyApi() => KeyImpl();

  /// Generates a new private key.
  ///
  /// Returns a [String] representing the generated private key.
  String generatePrivateKey();

  /// Returns the public key corresponding to the given private key.
  ///
  /// The [privateKey] parameter should be a [String] representing a private key.
  ///
  /// Returns a [String] representing the generated public key.
  String getPublicKey(String privateKey);
}
