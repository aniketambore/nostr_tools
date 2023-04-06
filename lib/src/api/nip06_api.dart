library api.nip06;

import '../impl/impl.dart';

/// An abstract class that provides methods for working with NIP-06, a Nostr protocol for generating private keys
/// from seed words, generating seed words, and validating seed words.
abstract class Nip06 {
  /// Creates an instance of [Nip06Impl], which is the default implementation of [Nip06].
  factory Nip06() => Nip06Impl();

  /// Returns a private key generated from the specified mnemonic seed words and optional passphrase.
  String privateKeyFromSeedWords(String mnemonic, {String passphrase = ''});

  /// Generates a string of seed words that can be used to generate a private key.
  String generateSeedWords();

  /// Returns `true` if the specified string of seed words is valid, and `false` otherwise.
  bool validateWords(String words);
}
