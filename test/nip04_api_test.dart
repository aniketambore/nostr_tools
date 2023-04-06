import 'package:nostr_tools/nostr_tools.dart';
import 'package:test/test.dart';

void main() {
  final keyGenerator = KeyApi();
  final sk1 = keyGenerator.generatePrivateKey();
  final pk1 = keyGenerator.getPublicKey(sk1);
  final sk2 = keyGenerator.generatePrivateKey();
  final pk2 = keyGenerator.getPublicKey(sk2);

  final plainText = "Hello, World!";
  group('Nip04', () {
    test('can encrypt and decrypt messages', () {
      final nip04 = Nip04();
      final cipherText = nip04.encrypt(sk1, pk2, plainText);
      final decryptedText = nip04.decrypt(sk2, pk1, cipherText);

      expect(decryptedText, equals(plainText));
    });

    test('throws error for invalid cipher text format', () {
      final nip04 = Nip04();
      final invalidCipherText = "invalid_cipher_text";
      expect(() => nip04.decrypt(sk1, pk2, invalidCipherText),
          throwsA(isA<ArgumentError>()));
    });
  });
}
