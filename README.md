<p align="center"><img src="https://i.ibb.co/VCLgK6k/package-logo.png" alt="nostr_tools package logo" /></p>
<p align="center">A Dart package that makes it easy to work with the <b>nostr</b> protocol and develop <b>nostr</b> clients.</p>

# Usage
To use this package, add `nostr_tools` as a dependency in your *pubspec.yaml* file.

## Generating a private key and a public key

```dart
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  final keyGenerator = KeyApi();

  final privateKey = keyGenerator.generatePrivateKey();
  print('[+] privateKey: $privateKey');
  // [+] privateKey: b2352adb186508e7f617105a6dc070df531f53b56cf8744816fdb838891dc9b7

  final publicKey = keyGenerator.getPublicKey(privateKey);
  print('[+] publicKey: $publicKey');
  // [+] publicKey: 9d088c4377b9866fad945d949de8f626784b1639f93bf090c1cea6727f17dd51
}
```

## Creating, signing and verifying events

```dart
import 'package:nostr_tools/nostr_tools.dart';

void main() {
  final keyApi = KeyApi();
  final eventApi = EventApi();

  final privateKey = keyApi.generatePrivateKey();
  final publicKey = keyApi.getPublicKey(privateKey);

  final event = Event(
    kind: 1,
    tags: [],
    content: 'content',
    created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    pubkey: publicKey,
  );

  event.id = eventApi.getEventHash(event);
  event.sig = eventApi.signEvent(event, privateKey);

  if (eventApi.verifySignature(event)) print('[+] sig is valid');
}
```

## Interacting with a relay

```dart
void main() async {
  final relay = RelayApi(relayUrl: 'wss://relay.damus.io');

  final stream = await relay.connect();

  relay.on((event) {
    if (event == RelayEvent.connect) {
      print('[+] connected to ${relay.relayUrl}');
    } else if (event == RelayEvent.error) {
      print('[!] failed to connect to ${relay.relayUrl}');
    }
  });

  relay.sub([
    Filter(
      kinds: [1],
      limit: 10,
      since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    )
  ]);

  stream.listen((Message message) {
    if (message.type == 'EVENT') {
      Event event = message.message;
      print('[+] Received event: ${event.content}');
    } else if (message.type == 'OK') {
      print('[+] Event Published: ${message.message}');
    }
  });

  // let's publish a new event while simultaneously monitoring the relay for it
  final privateKey =
      'b2352adb186508e7f617105a6dc070df531f53b56cf8744816fdb838891dc9b7';

  final event = EventApi().finishEvent(
    Event(
      kind: 1,
      tags: [],
      content: 'hello world',
      created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
    privateKey,
  );

  relay.publish(event);
}
```

## Interacting with multiple relays

```dart
void main() async {
  final relaysList = [
    'wss://relay.damus.io',
    'wss://relay.nostr.info',
    'wss://eden.nostr.land',
    'wss://nostr-pub.wellorder.net',
    'wss://nos.lol'
  ];
  final relayPool = RelayPoolApi(relaysList: relaysList);

  final stream = await relayPool.connect();

  relayPool.on((event) {
    if (event == RelayEvent.connect) {
      print('[+] connected to: ${relayPool.connectedRelays}');
    } else if (event == RelayEvent.error) {
      print('[!] failed to connect to: ${relayPool.failedRelays}');
    }
  });

  relayPool.sub([
    Filter(
      kinds: [1],
      limit: 10,
      since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    )
  ]);

  stream.listen((Message message) {
    if (message.type == 'EVENT') {
      Event event = message.message;
      print('[+] Received event: ${event.content}');
    }
  });

  final privateKey =
      'ccbe92bd853e3661bace63df5b8338dcbaa2c766e2dbb0b90d45b2dd58efaae4';

  final event = EventApi().finishEvent(
    Event(
      kind: 1,
      tags: [],
      content: 'hello world',
      created_at: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
    privateKey,
  );

  relayPool.publish(event);
}
```

## Querying profile data from a NIP-05 address

```dart
void main() async {
  var nip05 = Nip05();
  var profile = await nip05.queryProfile('anipy@aniketambore.github.io');
  print('[+] Pubkey: ${profile?.pubkey}');
  // [+] Pubkey: c7c187ba76532d55723490af88e76dd570fe551a2461ca9ab542b503bbb25045

  print('[+] Relays: ${profile?.relays}');
  // [+] Relays: [wss://relay.damus.io, wss://nos.lol, wss://relay.snort.social]
}
```

## Encoding and decoding NIP-19 codes

```dart
void main() {
  final keyGenerator = KeyApi();
  final nip19 = Nip19();

  final sk = keyGenerator.generatePrivateKey();
  final nsec = nip19.nsecEncode(sk);
  final nsecDecoded = nip19.decode(nsec);
  assert(nsecDecoded['type'] == 'nsec');
  assert(nsecDecoded['data'] == sk);

  final pk = keyGenerator.getPublicKey(sk);
  final npub = nip19.npubEncode(pk);
  final npubDecoded = nip19.decode(npub);
  assert(npubDecoded['type'] == 'npub');
  assert(npubDecoded['data'] == pk);

  final relays = [
    'wss://relay.nostr.example.mydomain.example.com',
    'wss://nostr.banana.com'
  ];
  final nprofile =
      nip19.nprofileEncode(ProfilePointer(pubkey: pk, relays: relays));
  final nprofileDecode = nip19.decode(nprofile);
  assert(nprofileDecode['type'] == 'nprofile');
  assert(nprofileDecode['data']['pubkey'] == pk);
  assert(nprofileDecode['data']['relays'].length == 2);
}
```

## Encrypting and decrypting direct messages

```dart
void main() {
  final keyGenerator = KeyApi();
  final nip04 = Nip04();

  final aliceSK = keyGenerator.generatePrivateKey();
  final alicePK = keyGenerator.getPublicKey(aliceSK);
  final bobSK = keyGenerator.generatePrivateKey();
  final bobPK = keyGenerator.getPublicKey(bobSK);

  var aliceMessageToBob = 'Hello Bob!';
  var cipherText = nip04.encrypt(aliceSK, bobPK, aliceMessageToBob);
  print('[+] cipherText: $cipherText');

  var bobDecodingMessage = nip04.decrypt(bobSK, alicePK, cipherText);
  print('[+] plainText: $bobDecodingMessage');
}
```

Take a look at the example project for developing a simple basic nostr client in flutter.

## Reference
- [nips](https://github.com/nostr-protocol/nips)
