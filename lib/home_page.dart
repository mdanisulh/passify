import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passify/password.dart';
import 'package:passify/change_password_dialog.dart';
import 'package:passify/utils/password_text_field.dart';
import 'package:passify/utils/salt_text_field.dart';
import 'package:passify/utils/show_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _salt;
  late final TextEditingController _masterPasswd;
  late final TextEditingController _passwdLength;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _salt = TextEditingController();
    _masterPasswd = TextEditingController();
    _passwdLength = TextEditingController();
    checkMasterPasswd();
    super.initState();
  }

  @override
  void dispose() {
    _salt.dispose();
    _masterPasswd.dispose();
    _passwdLength.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passify'),
        backgroundColor: Colors.white12,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'Change Master Password':
                  checkMasterPasswd(change: true);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'Change Master Password',
                  child: Text('Change Master Password'),
                ),
              ];
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(0, 191, 197, 197).withOpacity(.75), const Color(0x00000000)],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(1, 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SaltTextField(salt: _salt),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(30),
              child: PasswordTextField(masterPassword: _masterPasswd, hintText: 'Master Password', labelText: 'Enter your master password'),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _passwdLength,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Default=16',
                  label: Text(
                    'Password Length (8-32)',
                    style: TextStyle(color: Colors.white70),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70, width: 2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70, width: 3),
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: check,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white38,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                ),
                child: const Text(
                  "Get Password",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> check() async {
    final SharedPreferences prefs = await _prefs;
    var masterPasswd = _masterPasswd.text.trim();
    var name = _salt.text.trim();
    var passwdSHA = sha512.convert(utf8.encode(masterPasswd));
    final String? masterSHA = prefs.getString('masterSHA');
    if (name.isEmpty && context.mounted) {
      showSnackbar(context, 'Name must conatain at least one character!');
    } else if (passwdSHA.toString() == masterSHA) {
      String passwd;
      if ((_passwdLength.text.isNotEmpty && int.parse(_passwdLength.text) >= 8 && int.parse(_passwdLength.text) <= 32) || _passwdLength.text.isEmpty) {
        if (_passwdLength.text.isNotEmpty) {
          passwd = generate(salt: name, masterPassword: masterPasswd, passwordLength: int.parse(_passwdLength.text));
        } else {
          passwd = generate(salt: name, masterPassword: masterPasswd);
        }
        await Clipboard.setData(ClipboardData(text: passwd)).then((_) {
          showSnackbar(context, 'Password copied to clipboard successfully!');
        });
      } else {
        if (context.mounted) {
          showSnackbar(context, 'Password length must be between 8 and 32!');
        }
      }
    } else if (context.mounted) {
      showSnackbar(context, 'Incorrect Master Password!');
    }
  }

  Future<void> checkMasterPasswd({bool change = false}) async {
    final SharedPreferences prefs = await _prefs;
    final String? masterSHA = prefs.getString('masterSHA');
    if ((masterSHA == null || change) && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ChangePasswordDialog(prefs: prefs),
      );
    }
  }
}
