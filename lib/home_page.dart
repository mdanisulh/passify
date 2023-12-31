import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passify/password.dart';
import 'package:passify/change_password_dialog.dart';
import 'package:passify/utils/custom_text_field.dart';
import 'package:passify/utils/show_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _salt;
  late final TextEditingController _masterPassword;
  late final TextEditingController _passwordLength;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _salt = TextEditingController();
    _masterPassword = TextEditingController();
    _passwordLength = TextEditingController();
    checkMasterPassword();
    super.initState();
  }

  @override
  void dispose() {
    _salt.dispose();
    _masterPassword.dispose();
    _passwordLength.dispose();
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
                  checkMasterPassword(change: true);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: CustomTextField(
                controller: _salt,
                hintText: 'Enter the website/app name',
                labelText: 'Website/App Name',
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: CustomTextField(
                controller: _masterPassword,
                hintText: 'Enter your master password',
                labelText: 'Master Password',
                isPassword: true,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: CustomTextField(
                controller: _passwordLength,
                hintText: 'Default = 16',
                labelText: 'Password Length (4-32)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: check,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
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
    final String masterPassword = _masterPassword.text.trim();
    final String salt = _salt.text.trim();
    final String passwordSHA = sha512.convert(utf8.encode('passify:$masterPassword')).toString();
    final String? masterSHA = prefs.getString('masterSHA');
    if (salt.isEmpty && context.mounted) {
      showSnackbar(context, 'Name must conatain at least one character!');
    } else if (passwordSHA == masterSHA) {
      String password;
      if ((_passwordLength.text.isNotEmpty && int.parse(_passwordLength.text) >= 4 && int.parse(_passwordLength.text) <= 32) || _passwordLength.text.isEmpty) {
        if (_passwordLength.text.isNotEmpty) {
          password = generate(salt: salt, masterPassword: masterPassword, passwordLength: int.parse(_passwordLength.text));
        } else {
          password = generate(salt: salt, masterPassword: masterPassword);
        }
        await Clipboard.setData(ClipboardData(text: password)).then((_) {
          showSnackbar(context, 'Password copied to clipboard successfully!');
        });
      } else if (context.mounted) {
        showSnackbar(context, 'Password length must be between 4 and 32!');
      }
    } else if (context.mounted) {
      showSnackbar(context, 'Incorrect Master Password!');
    }
  }

  Future<void> checkMasterPassword({bool change = false}) async {
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
