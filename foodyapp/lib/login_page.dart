import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'home_page.dart'; // Pastikan ini sesuai dengan path file home_page.dart

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/user/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);

      // Navigasi ke halaman Home setelah login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${response.body}')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Foody',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .teal, // Add this line to set the text color to green
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                '"Share your delicious food experiences"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Input Username
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
              SizedBox(height: 20),
              // Input Password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                obscureText: true,
              ),
              SizedBox(height: 30),
              // Tombol Login
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Login',
                          style: TextStyle(fontSize: 16, color: Colors.teal)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              // Teks "Belum punya akun?"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                      style: TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "Register here",
                      style: TextStyle(fontSize: 14, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
