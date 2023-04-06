library impl.nip06;

import 'package:nostr_tools/src/utils/hex_util.dart';

import '../api/api.dart';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;

class Nip06Impl implements Nip06 {
  @override
  String privateKeyFromSeedWords(String mnemonic, {String passphrase = ''}) {
    final seed = bip39.mnemonicToSeed(mnemonic, passphrase: passphrase);
    final root = bip32.BIP32.fromSeed(seed);
    final path = "m/44'/1237'/0'/0/0";
    final privateKey = root.derivePath(path).privateKey;
    if (privateKey == null) {
      throw Exception('[!] could not derive private key');
    }
    return HexUtil.encode(privateKey);
  }

  @override
  String generateSeedWords() {
    return bip39.generateMnemonic();
  }

  @override
  bool validateWords(String words) {
    return bip39.validateMnemonic(words);
  }
}
