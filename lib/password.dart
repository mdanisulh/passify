import 'dart:convert';

import 'package:cryptography/cryptography.dart';

Future<List<int>> argon2id(String masterPassword, String salt) async {
  final algorithm = Argon2id(
    parallelism: 1,
    memory: 5000,
    iterations: 1,
    hashLength: 128,
  );
  final newSecretKey = await algorithm.deriveKey(
    secretKey: SecretKey(utf8.encode(masterPassword)),
    nonce: utf8.encode(salt),
  );
  final newSecretKeyBytes = await newSecretKey.extractBytes();
  return newSecretKeyBytes;
}

Future<String> generate({String salt = "", String masterPassword = "", int passwordLength = 16}) async {
  const String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
  List<int> saltedPasswordSHA = await argon2id(masterPassword, salt.toLowerCase().trim());
  String password = '';
  for (int i = 0; i < passwordLength; i++) {
    int asciiSum = 0;
    for (int j = 0; j < saltedPasswordSHA.length ~/ passwordLength; j++) {
      asciiSum += saltedPasswordSHA[i * (saltedPasswordSHA.length ~/ passwordLength) + j];
    }
    password += characters[asciiSum % characters.length];
  }
  String upper = characters[password.codeUnitAt(0) % 26];
  String lower = characters[26 + password.codeUnitAt(1) % 26];
  String digit = characters[52 + password.codeUnitAt(2) % 10];
  String special = characters[62 + password.codeUnitAt(3) % 10];
  password = '$upper$digit${password.substring(4)}$special$lower';
  return password;
}
