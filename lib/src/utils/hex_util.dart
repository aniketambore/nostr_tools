import 'dart:math';

import 'package:convert/convert.dart';

class HexUtil {
  static String encode(List<int> bytes) {
    return hex.encode(bytes);
  }

  static List<int> decode(String str) {
    return hex.decode(str);
  }

  static String generate64RandomHexChars() {
    final random = Random.secure();
    final randomBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return encode(randomBytes);
  }
}
