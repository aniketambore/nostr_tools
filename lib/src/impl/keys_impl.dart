library impl.keys;

import 'dart:math';

import '../api/api.dart';
import '../utils/utils.dart';

class KeyImpl implements KeyApi {
  final Random _random = Random.secure();

  @override
  String generatePrivateKey() {
    final randomBytes = List<int>.generate(32, (i) => _random.nextInt(256));
    return HexUtil.encode(randomBytes);
  }

  @override
  String getPublicKey(String privateKey) {
    return Bip340Util.getPublicKey(privateKey);
  }
}
