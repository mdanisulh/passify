import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController _masterPassword;
  final String? hintText;
  final String? labelText;
  const PasswordTextField({super.key, required TextEditingController masterPassword, this.hintText, this.labelText}) : _masterPassword = masterPassword;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(double borderRadius) => OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70, width: 2),
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        );
    return TextField(
      controller: widget._masterPassword,
      obscureText: !_passwordVisible,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        border: border(10),
        focusedBorder: border(15),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }
}
