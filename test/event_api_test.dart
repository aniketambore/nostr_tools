import 'package:nostr_tools/nostr_tools.dart';
import 'package:test/test.dart';

void main() {
  final keyGenerator = KeyApi();
  final eventApi = EventApi();
  group('getEventHash', () {
    test('should return the correct event hash', () {
      final privateKey =
          'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';

      final publicKey = keyGenerator.getPublicKey(privateKey);
      final unsignedEvent = Event(
        kind: 1,
        tags: [],
        content: 'Hello, world!',
        created_at: 1617932115,
        pubkey: publicKey,
      );

      final eventHash = eventApi.getEventHash(unsignedEvent);
      expect(eventHash.runtimeType, equals(String));
      expect(eventHash.length, equals(64));
    });
  });

  group('signEvent', () {
    test('should sign an event object', () {
      final privateKey =
          'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';
      final publicKey = keyGenerator.getPublicKey(privateKey);
      final unsignedEvent = Event(
        kind: 1,
        tags: [],
        content: 'Hello, world!',
        created_at: 1617932115,
        pubkey: publicKey,
      );

      unsignedEvent.id = eventApi.getEventHash(unsignedEvent);
      final sig = eventApi.signEvent(unsignedEvent, privateKey);
      unsignedEvent.sig = sig;

      // verify the signature
      final isValid = eventApi.verifySignature(unsignedEvent);

      expect(sig.runtimeType, equals(String));
      expect(sig.length, equals(128));
      expect(isValid, equals(true));
    });
  });

  test('should not sign an event with different private key', () {
    final privateKey =
        'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';
    final publicKey = keyGenerator.getPublicKey(privateKey);

    final wrongPrivateKey =
        'a91e2a9d9e0f70f0877bea0dbf034e8f95d7392a27a7f07da0d14b9e9d456be7';

    final unsignedEvent = Event(
      kind: 1,
      tags: [],
      content: 'Hello, world!',
      created_at: 1617932115,
      pubkey: publicKey,
    );

    unsignedEvent.id = eventApi.getEventHash(unsignedEvent);
    final sig = eventApi.signEvent(unsignedEvent, wrongPrivateKey);
    unsignedEvent.sig = sig;

    // verify the signature
    final isValid = eventApi.verifySignature(unsignedEvent);

    expect(sig.runtimeType, equals(String));
    expect(sig.length, equals(128));
    expect(isValid, equals(false));
  });

  group('verifySignature', () {
    test('should return true for a valid event signature', () {
      final privateKey =
          'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';

      final event = eventApi.finishEvent(
        Event(
          kind: 1,
          tags: [],
          content: 'Hello, world!',
          created_at: 1617932115,
        ),
        privateKey,
      );

      // verify the signature
      final isValid = eventApi.verifySignature(event);
      expect(isValid, equals(true));
    });

    test('should return false for an invalid event signature', () {
      final privateKey =
          'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';

      final event = eventApi.finishEvent(
        Event(
          kind: 1,
          tags: [],
          content: 'Hello, world!',
          created_at: 1617932115,
        ),
        privateKey,
      );

      // tamper with the signature
      event.sig = event.sig.replaceAll('0', '1');

      final isValid = eventApi.verifySignature(event);
      expect(isValid, equals(false));
    });

    test(
        'should return false when verifying an event with a different private key',
        () {
      final privateKey1 =
          'd217c1ff2f8a65c3e3a1740db3b9f58b8c848bb45e26d00ed4714e4a0f4ceecf';

      final privateKey2 =
          '5b4a34f4e4b23c63ad55a35e3f84a3b53d96dbf266edf521a8358f71d19cbf67';
      final publicKey2 = keyGenerator.getPublicKey(privateKey2);

      final event = eventApi.finishEvent(
        Event(
          kind: 1,
          tags: [],
          content: 'Hello, world!',
          created_at: 1617932115,
        ),
        privateKey1,
      );

      event.pubkey = publicKey2;
      final isValid = eventApi.verifySignature(event);
      expect(isValid, equals(false));
    });
  });
}
