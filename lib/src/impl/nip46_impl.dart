library impl.nip46;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bech32/bech32.dart';

import '../api/api.dart';
import '../models/models.dart';
import '../utils/utils.dart';


class Nip46Impl implements Nip46 {
  @override
  String connect(String hex) {
    return 'nsec1';
  }
}
