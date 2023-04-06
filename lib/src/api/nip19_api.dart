/// This library provides the interface for NIP-19 encoding and decoding.
library api.nip19;

import '../impl/impl.dart';
import '../models/models.dart';

/// The abstract class [Nip19] is the public API for encoding and decoding NIP-19 codes.
abstract class Nip19 {
  /// Creates a [Nip19Impl] instance.
  factory Nip19() => Nip19Impl();

  /// Encodes a given hexadecimal string into a NIP-19 'nsec' string.
  String nsecEncode(String hex);

  /// Encodes a given hexadecimal string into a NIP-19 'npub' string.
  String npubEncode(String hex);

  /// Encodes a given hexadecimal string into a NIP-19 'note' string.
  String noteEncode(String hex);

  /// Encodes a given [ProfilePointer] object into a NIP-19 'nprofile' string.
  String nprofileEncode(ProfilePointer profile);

  /// Encodes a given [EventPointer] object into a NIP-19 'nevent' string.
  String neventEncode(EventPointer event);

  /// Encodes a given [AddressPointer] object into a NIP-19 'naddr' string.
  String naddrEncode(AddressPointer addr);

  /// Decodes a given NIP-19 code into a [Map] of type and data.
  Map<String, dynamic> decode(String nip19);
}
