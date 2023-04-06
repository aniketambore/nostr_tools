import 'package:bip340/bip340.dart' as bip340;

class Bip340Util {
  static String getPublicKey(
    String privateKey,
  ) =>
      bip340.getPublicKey(
        privateKey,
      );

  static String sign(String privateKey, String id, String aux) => bip340.sign(
        privateKey,
        id,
        aux,
      );

  static bool verify(String publicKey, String id, String signature) =>
      bip340.verify(publicKey, id, signature);
}
