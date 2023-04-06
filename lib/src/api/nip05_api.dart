/// A library for querying profile data from a NIP-05 address.
library api.nip05;

import '../models/models.dart';
import '../impl/impl.dart';

/// An abstract class representing a NIP-05 implementation.
abstract class Nip05 {
  /// A factory method for creating an instance of the [Nip05] class.
  factory Nip05() => Nip05Impl();

  /// Queries the profile data for a given [fullname] and returns a
  /// [ProfilePointer] object, which contains the public key and relay
  /// information.
  ///
  /// Returns `null` if the profile data cannot be found for the given
  /// [fullname].
  Future<ProfilePointer?> queryProfile(String fullname);
}
