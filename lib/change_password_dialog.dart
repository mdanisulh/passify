import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:passify/utils/custom_text_field.dart';
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
            CustomTextField(
              controller: passwordController,
              hintText: 'New Master Passphrase',
              isPassword: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Master Passphrase',
              isPassword: true,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            final String password = passwordController.text.trim();
            final String confirmPassword = confirmPasswordController.text.trim();
            if (password == confirmPassword && password.length >= 8) {
              final String passwordSHA = sha512.convert(utf8.encode('passify:$password')).toString();
              await prefs.setString('masterSHA', passwordSHA);
              if (context.mounted) {
                Navigator.pop(context);
              }
            } else {
              if (password != confirmPassword) {
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
