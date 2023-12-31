import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController textController;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? labelText;
  const CustomTextField({super.key, required TextEditingController controller, this.hintText, this.labelText, this.isPassword = false, this.keyboardType}) : textController = controller;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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
      controller: widget.textController,
      obscureText: !_passwordVisible && widget.isPassword,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        border: border(10),
        focusedBorder: border(15),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
