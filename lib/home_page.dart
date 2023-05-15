import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_generator/password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late final TextEditingController _name;
  late final TextEditingController _masterPasswd;
  late final TextEditingController _passwdLength;

  bool _passwordVisible = false;
  bool errorPasswd = false;
  bool errorName = false;

  @override
  void initState() {
    _name = TextEditingController();
    _masterPasswd = TextEditingController();
    _passwdLength = TextEditingController();
    checkMasterPasswd();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _masterPasswd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? colorName = errorName ? Colors.red : Colors.white70;
    Color? colorPasswd = errorPasswd ? Colors.red : Colors.white70;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passwords'),
        backgroundColor: Colors.white12,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case "Change Master Password":
                  checkMasterPasswd(change: true);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: "Change Master Password",
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
            colors: [const Color.fromARGB(0, 191, 197, 197).withOpacity(.74), const Color(0x00000000)],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(1, 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _name,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  onTapOutside: (event) {
                    errorName = false;
                    setState(() {});
                  },
                  onChanged: (value) {
                    errorName = false;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the website/app name',
                    label: Text(
                      "Website/App Name",
                      style: TextStyle(color: colorName),
                    ),
                    helperText: errorName ? "Name must contain atleast one character" : null,
                    helperStyle: const TextStyle(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorName, width: 2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorName, width: 3),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _masterPasswd,
                  obscureText: !_passwordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  onTapOutside: (event) {
                    errorPasswd = false;
                    setState(() {});
                  },
                  onChanged: (value) {
                    errorPasswd = false;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your master password',
                    label: Text(
                      "Master Password",
                      style: TextStyle(color: colorPasswd),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorPasswd, width: 2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorPasswd, width: 3),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(15),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: colorPasswd,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwdLength,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Default=16',
                    label: Text(
                      "Password Length",
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
    var name = _name.text.trim();
    var passwdSHA = sha512.convert(utf8.encode(masterPasswd));
    final String? masterSHA = prefs.getString('masterSHA');
    if (name.isEmpty) {
      errorName = true;
      setState(() {});
    } else if (passwdSHA.toString() == masterSHA) {
      errorPasswd = false;
      errorName = false;
      String passwd;
      if ((_passwdLength.text.isNotEmpty && int.parse(_passwdLength.text) >= 8 && int.parse(_passwdLength.text) <= 32) || _passwdLength.text.isEmpty) {
        if (_passwdLength.text.isNotEmpty) {
          passwd = calculate(name: name, masterPasswd: masterPasswd, passwdLength: int.parse(_passwdLength.text));
        } else {
          passwd = calculate(name: name, masterPasswd: masterPasswd);
        }
        await Clipboard.setData(ClipboardData(text: passwd)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard successfully!')));
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password length must be between 8 and 32!')));
        }
      }
      setState(() {});
    } else {
      errorPasswd = true;
      _masterPasswd.text = "";
      setState(() {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong Password!')));
      }
    }
  }

  Future<void> checkMasterPasswd({bool change = false}) async {
    final SharedPreferences prefs = await _prefs;
    final String? masterSHA = prefs.getString('masterSHA');
    if (masterSHA != null && !change) {
      return;
    } else {
      late final TextEditingController textFieldController = TextEditingController();
      late final TextEditingController confirmController = TextEditingController();
      if (context.mounted) {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Enter new master password',
                style: TextStyle(fontSize: 20),
              ),
              content: SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextField(
                      controller: textFieldController,
                      obscureText: !_passwordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "New Master Passphrase",
                      ),
                    ),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "Confirm Master Passphrase",
                        helperText: "Password must have atleast 8 characters!",
                        helperStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    var text = textFieldController.text.trim();
                    var confirm = confirmController.text.trim();
                    if (text == confirm && text.length >= 8) {
                      var passwdSHA = sha512.convert(utf8.encode(text));
                      await prefs.setString('masterSHA', passwdSHA.toString());
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      if (text != confirm) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords does not match!')));
                      } else if (text.length < 8) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must have at least 8 characters!')));
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }
}
