import 'dart:convert';

import 'package:crypto/crypto.dart';

String generate({String salt = "", String masterPassword = "", int passwordLength = 16}) {
  const String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
  String saltedPassword = '${salt.toLowerCase().trim()}:$masterPassword';
  String saltedPasswordSHA = sha512.convert(utf8.encode(saltedPassword)).toString();
  String password = '';
  for (int i = 0; i < passwordLength; i++) {
    int asciiSum = 0;
    for (int j = 0; j < saltedPasswordSHA.length ~/ passwordLength; j++) {
      asciiSum += saltedPasswordSHA.codeUnitAt(i * (saltedPasswordSHA.length ~/ passwordLength) + j);
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
