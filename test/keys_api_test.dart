import 'package:test/test.dart';
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  final keyGenerator = KeyApi();

  test('test private key generation', () {
    expect(keyGenerator.generatePrivateKey(), matches(RegExp('[a-f0-9]{64}')));
  });

  test('test public key generation', () {
    expect(keyGenerator.getPublicKey(keyGenerator.generatePrivateKey()),
        matches(RegExp('[a-f0-9]{64}')));
  });

  test('test public key from private key deterministic', () {
    final sk = keyGenerator.generatePrivateKey();
    final pk = keyGenerator.getPublicKey(sk);

    for (var i = 0; i < 5; i++) {
      expect(keyGenerator.getPublicKey(sk), equals(pk));
    }
  });
}
