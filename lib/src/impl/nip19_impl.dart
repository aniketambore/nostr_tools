library impl.nip19;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bech32/bech32.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../utils/utils.dart';

typedef TLV = Map<int, List<Uint8List>>;

class Nip19Impl implements Nip19 {
  static const _bech32MaxSize = 5000;

  List<int> _convertBits(List<int> data, int fromBits, int toBits, bool pad) {
    int acc = 0;
    int bits = 0;
    List<int> ret = [];
    for (int value in data) {
      acc = (acc << fromBits) | value;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        ret.add((acc >> bits) & ((1 << toBits) - 1));
      }
    }
    if (pad) {
      if (bits > 0) {
        ret.add((acc << (toBits - bits)) & ((1 << toBits) - 1));
      }
    } else if (bits >= fromBits || (acc & ((1 << bits) - 1)) != 0) {
      throw Exception('[!] Invalid padding');
    }
    return ret;
  }

  String _encodeBytes(String prefix, String hex) {
    final bytes = HexUtil.decode(hex);
    List<int> fiveBitWords = _convertBits(bytes, 8, 5, true);
    var bech32String = const Bech32Codec().encode(Bech32(prefix, fiveBitWords));
    return bech32String;
  }

  TLV _parseTLV(Uint8List data) {
    TLV result = {};
    Uint8List rest = data;
    while (rest.isNotEmpty) {
      int t = rest[0];
      int l = rest[1];
      Uint8List v = rest.sublist(2, 2 + l);
      rest = rest.sublist(2 + l);
      if (v.length < l) continue;
      result[t] = result[t] ?? [];
      result[t]?.add(v);
    }

    return result;
  }

  Uint8List _concatBytes(List<Uint8List> bytesList) {
    int length = bytesList.fold(0, (sum, bytes) => sum + bytes.length);
    Uint8List result = Uint8List(length);
    int offset = 0;
    for (Uint8List bytes in bytesList) {
      result.setRange(offset, offset + bytes.length, bytes);
      offset += bytes.length;
    }
    return result;
  }

  Uint8List _encodeTLV(TLV tlv) {
    List<Uint8List> entries = [];
    for (var entry in tlv.entries) {
      for (var v in entry.value) {
        Uint8List bytes = Uint8List(v.length + 2);
        bytes.setRange(0, 1, [entry.key]);
        bytes.setRange(1, 2, [v.length]);
        bytes.setRange(2, v.length + 2, v);
        entries.add(bytes);
      }
    }

    return _concatBytes(entries);
  }

  @override
  String nsecEncode(String hex) {
    return _encodeBytes('nsec', hex);
  }

  @override
  String npubEncode(String hex) {
    return _encodeBytes('npub', hex);
  }

  @override
  String noteEncode(String hex) {
    return _encodeBytes('note', hex);
  }

  @override
  String naddrEncode(AddressPointer addr) {
    Uint8List kind = Uint8List(4)
      ..buffer.asByteData().setUint32(0, addr.kind, Endian.big);

    var identifier = utf8.encode(addr.identifier);
    List<Uint8List> relays = (addr.relays ?? [])
        .map((url) => utf8.encode(url))
        .toList()
        .cast<Uint8List>();
    Uint8List pubkeyBytes = Uint8List.fromList(HexUtil.decode(addr.pubkey));

    TLV tlv = {
      0: [identifier].cast<Uint8List>(),
      1: relays,
      2: [pubkeyBytes].cast<Uint8List>(),
      3: [kind].cast<Uint8List>(),
    };

    Uint8List data = _encodeTLV(tlv);
    List<int> fiveBitWords = _convertBits(data, 8, 5, true);
    var bech32String = const Bech32Codec()
        .encode(Bech32('naddr', fiveBitWords), _bech32MaxSize);
    return bech32String;
  }

  @override
  String neventEncode(EventPointer event) {
    Uint8List id = Uint8List.fromList(HexUtil.decode(event.id));
    List<Uint8List> relayUrls =
        (event.relays ?? []).map(utf8.encode).toList().cast<Uint8List>();
    List<Uint8List> author = event.author != null
        ? Uint8List.fromList(HexUtil.decode(event.author!))
            .toList()
            .cast<Uint8List>()
        : [];

    TLV tlv = {
      0: [id],
      1: relayUrls,
      2: author,
    };

    Uint8List data = _encodeTLV(tlv);

    List<int> fiveBitWords = _convertBits(data, 8, 5, true);

    var bech32String = const Bech32Codec()
        .encode(Bech32('nevent', fiveBitWords), _bech32MaxSize);
    return bech32String;
  }

  @override
  String nprofileEncode(ProfilePointer profile) {
    Uint8List pubkeyBytes = Uint8List.fromList(HexUtil.decode(profile.pubkey));

    List<Uint8List> relayUrls =
        (profile.relays ?? []).map(utf8.encode).toList().cast<Uint8List>();

    TLV tlv = {
      0: [pubkeyBytes],
      1: relayUrls,
    };

    Uint8List data = _encodeTLV(tlv);

    List<int> fiveBitWords = _convertBits(data, 8, 5, true);

    var bech32String = const Bech32Codec()
        .encode(Bech32('nprofile', fiveBitWords), _bech32MaxSize);
    return bech32String;
  }

  @override
  Map<String, dynamic> decode(String nip19) {
    Bech32 bech32;
    try {
      bech32 = const Bech32Codec().decode(nip19, _bech32MaxSize);
    } catch (e) {
      throw ChecksumVerificationException('Checksum verification failed');
    }

    List<int> data = _convertBits(bech32.data, 5, 8, false);
    final prefix = bech32.hrp;

    switch (prefix) {
      case 'nprofile':
        TLV tlv = _parseTLV(Uint8List.fromList(data));
        if (tlv[0]?.isEmpty ?? true) {
          throw Exception('missing TLV 0 for nprofile');
        }
        if (tlv[0]?.isNotEmpty ?? false) {
          if (tlv[0]![0].length != 32) {
            throw Exception('TLV 0 should be 32 bytes');
          }
        } else {
          throw Exception('missing TLV 0 for nprofile');
        }
        return {
          'type': 'nprofile',
          'data': {
            'pubkey': HexUtil.encode(tlv[0]![0]),
            'relays': tlv[1]?.map((d) => utf8.decode(d)).toList() ?? [],
          },
        };

      case 'nevent':
        TLV tlv = _parseTLV(Uint8List.fromList(data));
        if (tlv[0] == null) {
          throw Exception('missing TLV 0 for nevent');
        }
        if (tlv[0]![0].length != 32) {
          throw Exception('TLV 0 should be 32 bytes');
        }
        if (tlv[2] != null && tlv[2]![0].length != 32) {
          throw Exception('TLV 2 should be 32 bytes');
        }

        return {
          'type': 'nevent',
          'data': {
            'id': HexUtil.encode(tlv[0]![0]),
            'relays': tlv[1] != null
                ? tlv[1]!.map((e) => utf8.decode(e)).toList()
                : [],
            'author': tlv[2] != null ? HexUtil.encode(tlv[2]![0]) : null,
          },
        };

      case 'naddr':
        TLV tlv = _parseTLV(Uint8List.fromList(data));
        if (tlv[0] == null) {
          throw Exception('missing TLV 0 for naddr');
        }
        if (tlv[0] == null) {
          throw Exception('missing TLV 0 for naddr');
        }
        if (tlv[0] == null) {
          throw Exception('missing TLV 0 for naddr');
        }
        if (tlv[3] == null) {
          throw Exception('missing TLV 3 for naddr');
        }
        if (tlv[3]![0].length != 4) {
          throw Exception('TLV 3 should be 4 bytes');
        }
        return {
          'type': 'naddr',
          'data': {
            'identifier': utf8.decode(tlv[0]![0]),
            'pubkey': HexUtil.encode(tlv[2]![0]),
            'kind': int.parse(HexUtil.encode(tlv[3]![0]), radix: 16),
            'relays': tlv[1] != null
                ? tlv[1]!.map((d) => utf8.decode(d)).toList()
                : [],
          }
        };

      case 'nsec':
      case 'npub':
      case 'note':
        return {'type': prefix, 'data': HexUtil.encode(data)};
      default:
        throw Exception('unknown prefix $prefix');
    }
  }
}
