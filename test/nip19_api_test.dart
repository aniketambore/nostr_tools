import 'package:test/test.dart';
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  final keyGenerator = KeyApi();
  final nip19 = Nip19();
  test('encode and decode nsec', () {
    final sk = keyGenerator.generatePrivateKey();
    final nsec = nip19.nsecEncode(sk);
    expect(nsec, matches(RegExp(r'nsec1\w+')));
    final decoded = nip19.decode(nsec);
    expect(decoded['type'], equals('nsec'));
    expect(decoded['data'], equals(sk));
  });

  test('encode and decode npub', () {
    final sk = keyGenerator.generatePrivateKey();
    final pk = keyGenerator.getPublicKey(sk);
    final npub = nip19.npubEncode(pk);
    expect(npub, matches(RegExp(r'npub1\w+')));
    final decoded = nip19.decode(npub);
    expect(decoded['type'], equals('npub'));
    expect(decoded['data'], equals(pk));
  });

  group('nprofile tests', () {
    test('encode and decode nprofile', () {
      final sk = keyGenerator.generatePrivateKey();
      final pk = keyGenerator.getPublicKey(sk);
      List<String> relays = [
        'wss://relay.nostr.example.mydomain.example.com',
        'wss://nostr.banana.com'
      ];
      String nprofile =
          nip19.nprofileEncode(ProfilePointer(pubkey: pk, relays: relays));
      expect(nprofile, matches(RegExp(r'nprofile1\w+')));

      var result = nip19.decode(nprofile);
      expect(result['type'], equals('nprofile'));
      expect(result['data']['pubkey'], equals(pk));
      expect(result['data']['relays'], contains(relays[0]));
      expect(result['data']['relays'], contains(relays[1]));
    });

    test('decode nprofile without relays', () {
      String pubkey =
          '97c70a44366a6535c145b333f973ea86dfdc2d7a99da618c40c64705ad98e322';
      var result =
          nip19.decode(nip19.nprofileEncode(ProfilePointer(pubkey: pubkey)));

      expect(result['type'], equals('nprofile'));
      expect(result['type'], equals('nprofile'));
      expect(result['data']['relays'], isEmpty);
    });
  });

  group('naddr tests', () {
    test('encode and decode naddr', () {
      final sk = keyGenerator.generatePrivateKey();
      final pk = keyGenerator.getPublicKey(sk);
      List<String> relays = [
        'wss://relay.nostr.example.mydomain.example.com',
        'wss://nostr.banana.com'
      ];

      var naddr = nip19.naddrEncode(AddressPointer(
        identifier: 'banana',
        pubkey: pk,
        kind: 30023,
        relays: relays,
      ));
      expect(naddr, matches(RegExp(r'naddr1\w+')));

      var decoded = nip19.decode(naddr);
      expect(decoded['type'], equals('naddr'));
      expect(decoded['data']['pubkey'], equals(pk));
      expect(decoded['data']['relays'], contains(relays[0]));
      expect(decoded['data']['relays'], contains(relays[1]));
      expect(decoded['data']['kind'], equals(30023));
      expect(decoded['data']['identifier'], equals('banana'));
    });

    test('decode naddr from habla.news', () {
      var decoded = nip19.decode(
          'naddr1qq98yetxv4ex2mnrv4esygrl54h466tz4v0re4pyuavvxqptsejl0vxcmnhfl60z3rth2xkpjspsgqqqw4rsf34vl5');
      expect(decoded['type'], equals('naddr'));
      expect(
          decoded['data']['pubkey'],
          equals(
              '7fa56f5d6962ab1e3cd424e758c3002b8665f7b0d8dcee9fe9e288d7751ac194'));
      expect(decoded['data']['kind'], equals(30023));
      expect(decoded['data']['identifier'], equals('references'));
    });

    test('decode naddr from go-nostr with different TLV ordering', () {
      var decoded = nip19.decode(
          'naddr1qqrxyctwv9hxzq3q80cvv07tjdrrgpa0j7j7tmnyl2yr6yr7l8j4s3evf6u64th6gkwsxpqqqp65wqfwwaehxw309aex2mrp0yhxummnw3ezuetcv9khqmr99ekhjer0d4skjm3wv4uxzmtsd3jjucm0d5q3vamnwvaz7tmwdaehgu3wvfskuctwvyhxxmmd0zfmwx');
      expect(decoded['type'], equals('naddr'));
      expect(
          decoded['data']['pubkey'],
          equals(
              '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d'));
      expect(decoded['data']['relays'],
          contains('wss://relay.nostr.example.mydomain.example.com'));

      expect(decoded['data']['relays'], contains('wss://nostr.banana.com'));

      expect(decoded['data']['kind'], equals(30023));
      expect(decoded['data']['identifier'], equals('banana'));
    });
  });
}
