import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verify_page.dart'; // Import halaman verify
import 'login_page.dart'; // Import halaman login

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _username, _email, _password;

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/user/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _username,
        'email': _email,
        'password': _password,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final verificationCode = data[
          'verification_code']; // Asumsikan backend mengembalikan kode verifikasi

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'A verification code has been sent to your email. Please check your email!'),
          backgroundColor: Colors.teal,
        ),
      );

      // Arahkan ke halaman VerifyPage setelah menampilkan pesan
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyPage(
              email: _email!,
              verificationCode: verificationCode,
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Foody',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Welcome, please sign up your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  onSaved: (value) => _username = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _email = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  obscureText: true,
                  onSaved: (value) => _password = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState?.save();
                    _register();
                  },
                  child: Text('Register',
                      style: TextStyle(fontSize: 18, color: Colors.teal)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
