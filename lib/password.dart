import 'dart:convert';

import 'package:crypto/crypto.dart';

String calculate(String name, String masterPasswd) {
  String ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*", passwd = "";
  int masterPasswdSize = masterPasswd.length, nameSize = name.length, n = ch.length, passwdLength = 16;
  name = name.toLowerCase();
  masterPasswd = "_${masterPasswd}_";
  name = "_${name}_";
  for (int i = 1, j = 1, k = 1; k <= passwdLength; i++, j++, k++) {
    if (i > nameSize) {
      i = 1;
    }
    if (j > masterPasswdSize) {
      j = 1;
    }
    passwd += ch[(name.codeUnitAt(i - 1) + name.codeUnitAt(i) + name.codeUnitAt(i + 1) + masterPasswd.codeUnitAt(j - 1) + masterPasswd.codeUnitAt(j) + masterPasswd.codeUnitAt(j + 1)) % n];
  }
  passwdLength -= 4;
  var passwdSHA = sha512.convert(utf8.encode(passwd)).toString();
  passwd = "";
  for (int i = 0, k = 0; i < passwdLength; i++) {
    int asciiSum = 0;
    for (int j = 0; j < 128 ~/ passwdLength; j++, k++) {
      asciiSum += passwdSHA.codeUnitAt(k);
    }
    passwd += ch[asciiSum % n];
  }
  int sum = (nameSize % 9 == 0) ? 9 : (nameSize % 9);
  passwd = "${name[1].toUpperCase()}$passwd@$sum${name[nameSize].toLowerCase()}";
  return passwd;
}
