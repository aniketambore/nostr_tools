import 'package:test/test.dart';
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  final keyGenerator = KeyApi();
  final nip46 = Nip46();
  test('encode and decode nsec', () {
    final sk = keyGenerator.generatePrivateKey();
    final nsec = nip46.connect("test");
    expect(nsec, matches("nsec1"));
  });
}
