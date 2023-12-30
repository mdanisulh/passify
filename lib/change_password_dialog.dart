import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:passify/utils/password_text_field.dart';
import 'package:passify/utils/show_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordDialog extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final SharedPreferences prefs;

  ChangePasswordDialog({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Enter new master password',
        style: TextStyle(fontSize: 20),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PasswordTextField(masterPassword: passwordController, hintText: 'New Master Passphrase'),
            const SizedBox(height: 20),
            PasswordTextField(masterPassword: confirmPasswordController, hintText: 'Confirm Master Passphrase'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            var text = passwordController.text.trim();
            var confirm = confirmPasswordController.text.trim();
            if (text == confirm && text.length >= 8) {
              var passwdSHA = sha512.convert(utf8.encode(text));
              await prefs.setString('masterSHA', passwdSHA.toString());
              if (context.mounted) {
                Navigator.pop(context);
              }
            } else {
              if (text != confirm) {
                showSnackbar(context, 'Passwords does not match!');
              } else {
                showSnackbar(context, 'Password must have at least 8 characters!');
              }
            }
          },
        ),
        TextButton(
          onPressed: () {
            if (prefs.getString('masterSHA') != null) {
              Navigator.pop(context);
            } else {
              showSnackbar(context, 'Please set a master password!');
            }
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
