import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  VerifyPage({required this.email, required this.verificationCode});

  @override
  _VerifyPageState createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Menampilkan kode verifikasi setelah 2 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _codeController.text = widget.verificationCode;
      });
    });
  }

  Future<void> _verifyCode() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/user/verify-email/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': widget.email,
        'code': _codeController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification is success, you are ready to go!'),
          backgroundColor: Colors.teal,
        ),
      );

      // Arahkan ke halaman login setelah menampilkan pesan sukses
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${response.body}')),
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
                  'Email Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Enter the 6-digit code sent to',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, letterSpacing: 2.0),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text('Verify',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        Colors.teal, // Set the button color to teal
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
