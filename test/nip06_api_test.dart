import 'package:nostr_tools/nostr_tools.dart';
import 'package:test/test.dart';

void main() {
  final nip06 = Nip06();
  test('generate private key from a mnemonic', () {
    final mnemonic = 'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong';
    final privateKey = nip06.privateKeyFromSeedWords(mnemonic);
    expect(privateKey,
        'c26cf31d8ba425b555ca27d00ca71b5008004f2f662470f8c8131822ec129fe2');
  });

  test('generate private key from a mnemonic and passphrase', () async {
    final mnemonic = 'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong';
    final passphrase = '123';
    final privateKey =
        nip06.privateKeyFromSeedWords(mnemonic, passphrase: passphrase);
    expect(privateKey,
        '55a22b8203273d0aaf24c22c8fbe99608e70c524b17265641074281c8b978ae4');
  });
}
