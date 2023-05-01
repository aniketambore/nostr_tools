import 'package:test/test.dart';
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  var testUri = {
    'metadata': {
      'name': 'Nostr-Tools-App',
      'description':
        'Enabling the first generation of nostr apps',
      'url': 'https://vulpem.com',
      'icons': ['https://vulpem.com/1000x860-p-500.422be1bc.png'],
    },
    'relay': 'wss://nostr.vulpem.com',
    'target': 'b889ff5b1513b641e2a139f661a661364979c5beee91842f8f0ef42ab558e9d4',
  };

  final nip46 = Nip46(target: testUri['target'] as String, relay: testUri['relay'] as String, metaData: testUri['metadata'] as dynamic);

  test('fromURI', () {
    final url = nip46.fromURI(nip46.toString());
    expect(url.target, equals(testUri['target']));
    expect(url.relay, equals(testUri['relay']));
    expect(url.metaData, equals(testUri['metadata']));
  });

  test('connect', () {
    final connect = nip46.connect({});
    expect(connect, equals('fromconnectURI return'));
  });
}
