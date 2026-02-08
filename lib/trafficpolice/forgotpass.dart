import 'dart:convert';
import 'package:aismarttrafficlight/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const forgotpassword());
}

class forgotpassword extends StatelessWidget {
  const forgotpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: forgot_password(),
    );
  }
}

class forgot_password extends StatefulWidget {
  const forgot_password({super.key});

  @override
  State<forgot_password> createState() => _forgot_passwordState();
}

class _forgot_passwordState extends State<forgot_password> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendData() async {
    String email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? baseUrl = prefs.getString('url');

      if (baseUrl == null || baseUrl.isEmpty) {
        Fluttertoast.showToast(msg: "Server not configured");
        return;
      }

      var response = await http.post(
        Uri.parse('$baseUrl/android_forget_password_post/'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          Fluttertoast.showToast(
            msg: "Password sent to your email!",
            backgroundColor: Colors.green[700],
            textColor: Colors.white,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MyLoginPage(title: '')),
                (route) => false,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Email not registered",
            backgroundColor: Colors.orange[700],
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Server error, try again later");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "No internet connection");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A148C),  // Deep Purple
              Color(0xFF7B1FA2),
              Color(0xFFAB47BC),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Luxury Icon with Gold Glow
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFFFD700), width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      size: 90,
                      color: Color(0xFFFFD700), // Rich Gold
                    ),
                  ),
              
                  const SizedBox(height: 40),
              
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 16),
              
                  const Text(
                    "Enter your registered email address and we'll send your password instantly.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
              
                  const SizedBox(height: 60),
              
                  // Email Field - Glassmorphic Purple Style
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "you@example.com",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFFFFD700)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 60),
              
                  // Golden Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700), // Gold
                        foregroundColor: Colors.black87,
                        elevation: 15,
                        shadowColor: const Color(0xFFFFD700).withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      )
                          : const Text(
                        "SEND PASSWORD",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}