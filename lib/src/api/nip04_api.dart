library api.nip04;

import '../impl/impl.dart';

/// An abstract class that provides functionality to encrypt and decrypt direct messages.
abstract class Nip04 {
  /// A factory constructor that returns an implementation of the [Nip04] class.
  factory Nip04() => Nip04Impl();

  /// Encrypts the [text] using the private key [privKey] of the sender and the public key [pubKey] of the receiver.
  ///
  /// Returns the encrypted message in the form of a string.
  String encrypt(String privKey, String pubKey, String text);

  /// Decrypts the [cipherText] using the private key [privKey] of the receiver and the public key [pubKey] of the sender.
  ///
  /// Returns the decrypted message in the form of a string.
  String decrypt(String privKey, String pubKey, String cipherText);
}
