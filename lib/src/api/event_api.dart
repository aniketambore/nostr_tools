/// A library for creating and signing events.
///
/// To create and sign an event, create an instance of [EventApi] using its default
/// constructor, and then call the methods [getEventHash()], [signEvent()],
/// and [verifySignature()]. For example:
///
/// ```dart
/// import 'package:nostr_tools/nostr_tools.dart';
///
/// void main() {
///   final keyApi = KeyApi();
///   final eventApi = EventApi();
///
///   final privateKey = keyApi.generatePrivateKey();
///   final publicKey = keyApi.getPublicKey(privateKey);
///
///   final event = Event(
///     kind: 1,
///     tags: [],
///     content: 'content',
///     created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
///     pubkey: publicKey,
///   );
///
///   event.id = eventApi.getEventHash(event);
///   event.sig = eventApi.signEvent(event, privateKey);
///
///   if (eventApi.verifySignature(event)) print('[+] sig is valid');
/// }
/// ```
library api.event;

import '../models/models.dart';
import '../impl/impl.dart';

/// An abstract class representing an event generator and signer.
abstract class EventApi {
  /// Constructs an [EventApi] instance.
  ///
  /// By default, this constructor returns an [EventImpl] instance, which
  /// implements the [EventApi] interface.
  factory EventApi() => EventImpl();

  /// Generates the hash of the given [event].
  ///
  /// The [event] parameter should be an instance of the [Event] class.
  ///
  /// Returns a [String] representing the hash of the event.
  String getEventHash(Event event);

  /// Signs the given [event] using the specified [privateKey].
  ///
  /// The [event] parameter should be an instance of the [Event] class.
  /// The [privateKey] parameter should be a [String] representing a private key.
  ///
  /// Returns a [String] representing the signature of the event.
  String signEvent(Event event, String privateKey);

  /// Verifies the signature of the given [event].
  ///
  /// The [event] parameter should be an instance of the [Event] class.
  ///
  /// Returns a [bool] indicating whether the signature of the event is valid.
  bool verifySignature(Event event);

  /// Finishes signing the given [event] using the specified [privateKey].
  ///
  /// The [event] parameter should be an instance of the [Event] class.
  /// The [privateKey] parameter should be a [String] representing a private key.
  ///
  /// Returns a new [Event] instance with the updated [id] and [sig] fields.
  Event finishEvent(Event event, String privateKey);
}
