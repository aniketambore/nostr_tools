import 'dart:convert';

import 'package:http/http.dart';
import 'package:nostr_tools/nostr_tools.dart';
import 'package:nostr_tools/src/impl/impl.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';

void main() {
  group('nip05', () {
    final nip05 = Nip05();

    test('throws an ArgumentError if fullname is empty', () async {
      final query = nip05.queryProfile('');
      expect(query, throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('throws an ArgumentError if fullname is not in the expected format',
        () async {
      final query = nip05.queryProfile('john_doe');
      expect(query, throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('throws an ArgumentError if domain is not in the expected format',
        () async {
      final query = nip05.queryProfile('john_doe@');
      expect(query, throwsA(const TypeMatcher<ArgumentError>()));
    });

    test('returns null if the http request fails', () async {
      final httpClient = MockClient((request) async {
        return Response('Failed to fetch', 500);
      });

      final query = await Nip05Impl(httpClient: httpClient)
          .queryProfile('john_doe@domain.com');
      expect(query, null);
    });

    test('returns a ProfilePointer object when the http request is successful',
        () async {
      final httpClient = MockClient((request, {body, headers}) async {
        final Map<String, dynamic> jsonResponse = {
          'names': {'john_doe': 'public_key'},
          'relays': {
            'public_key': ['relay1', 'relay2']
          }
        };
        return Response(jsonEncode(jsonResponse), 200);
      });

      final query = await Nip05Impl(httpClient: httpClient)
          .queryProfile('john_doe@domain.com');
      expect(query, isA<ProfilePointer>());
    });
  });
}
