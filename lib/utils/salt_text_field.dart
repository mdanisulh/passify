import 'package:flutter/material.dart';

class SaltTextField extends StatefulWidget {
  final TextEditingController _salt;
  const SaltTextField({super.key, required TextEditingController salt}) : _salt = salt;

  @override
  State<SaltTextField> createState() => _SaltTextFieldState();
}

class _SaltTextFieldState extends State<SaltTextField> {
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(double borderRadius) => OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: widget._salt,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter the website/app name',
          label: const Text(
            'Website/App Name',
            style: TextStyle(color: Colors.white70),
          ),
          border: border(10),
          focusedBorder: border(15),
        ),
      ),
    );
  }
}
