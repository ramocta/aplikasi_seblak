import 'package:flutter/material.dart';
import 'package:seblak_say_cafe/views/admin/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _hide = true;
  String? _error;

  void _login() {
  if (_username.text.isEmpty || _password.text.isEmpty) {
    setState(() {
      _error = "Username & Password wajib diisi!";
    });
    return;
  }

  if (_username.text == "ilma" && _password.text == "1234") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Home(),
      ),
    );
  } else {
    setState(() {
      _error = "Username atau password salah!";
    });
  }
}

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xDEDE3905),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Login",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(height: 2, width: 50, color: Colors.red),

                  const SizedBox(height: 20),

                  // ERROR
                  if (_error != null)
                    Text(_error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),

                  const SizedBox(height: 10),

                  // USERNAME
                  const Text("Username"),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _username,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PASSWORD
                  const Text("Password"),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _password,
                      obscureText: _hide,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: !_hide,
                        onChanged: (v) {
                          setState(() {
                            _hide = !(v ?? false);
                          });
                        },
                      ),
                      const Text("View password"),
                      const Spacer(),
                      const Text("Forgot password?",
                          style: TextStyle(color: Colors.blue)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BUTTON LOGIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xDEDE3905),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}