library impl.nip05;

import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../api/api.dart';
import '../models/models.dart';

class Nip05Impl implements Nip05 {
  Nip05Impl({
    @visibleForTesting Client? httpClient,
  }) : _httpClient = httpClient ?? Client();

  final Client _httpClient;

  @override
  Future<ProfilePointer?> queryProfile(String fullname) async {
    if (fullname.isEmpty) {
      throw ArgumentError('Fullname cannot be empty');
    }

    final parts = fullname.split('@');
    if (parts.length != 2) {
      throw ArgumentError('Invalid fullname format');
    }

    final name = parts[0];
    final domain = parts[1];

    if (!domain.contains('.')) {
      throw ArgumentError('Invalid domain name');
    }

    if (!RegExp(r'^[A-Za-z0-9-_]+$').hasMatch(name)) {
      throw ArgumentError('Invalid name');
    }

    try {
      final url = Uri.https(domain, '/.well-known/nostr.json', {'name': name});
      final response = await _httpClient.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      final jsonResponse = jsonDecode(response.body);
      final nameToPubkeyMapping =
          jsonResponse['names'] as Map<String, dynamic>?;
      final pubkeyToRelaysMapping =
          jsonResponse['relays'] as Map<String, dynamic>?;
      final pubkey = nameToPubkeyMapping?[name] as String?;
      final relayList = pubkeyToRelaysMapping?[pubkey ?? ''] as List<dynamic>?;
      final relaysResult = relayList?.map((r) => r as String).toList() ?? [];

      if (pubkey != null) {
        return ProfilePointer(pubkey: pubkey, relays: relaysResult);
      } else {
        return null;
      }
    } on FormatException {
      return null;
    } on ClientException {
      return null;
    }
  }
}
