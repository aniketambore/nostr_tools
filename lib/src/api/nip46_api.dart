/// This library provides the interface for NIP-46 encoding and decoding.
library api.nip46;

import '../impl/impl.dart';
import '../models/models.dart';

/// The abstract class [Nip46] is the public API for encoding and decoding NIP-46 codes.
abstract class Nip46 {
  /// Creates a [Nip46Impl] instance.
  factory Nip46() => Nip46Impl();

  /// Encodes a given hexadecimal string into a NIP-46 'nsec' string.
  String connect(String hex);
}