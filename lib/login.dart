import 'dart:convert';
import 'package:aismarttrafficlight/trafficpolice/forgotpass.dart';
import 'package:aismarttrafficlight/trafficpolice/tphome.dart';
import 'package:aismarttrafficlight/user/home.dart';
import 'package:aismarttrafficlight/user/signup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'emergencyvehicle/evhome.dart';
import 'emergencyvehicle/signup.dart';
import 'main.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyLoginPage(title: 'Login'),
  ));
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _usernametextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IPSetupPage()),
        );
        return false;
      },
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4A148C), // Deep Purple
                Color(0xFF7B1FA2),
                Color(0xFFAB47BC),
                Color(0xFFE1BEE7),
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Luxury Logo & Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.amber, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.security_rounded, size: 80, color: Colors.amber),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const Text(
                    "Sign in to continue",
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),

                  const SizedBox(height: 50),

                  // Email Field
                  _buildGlassField(
                    controller: _usernametextController,
                    hint: "Enter your email",
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Password Field
                  _buildGlassField(
                    controller: _passwordtextController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),

                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const forgot_password()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _send_data,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        elevation: 15,
                        shadowColor: Colors.amber.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black87)
                          : const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  const Text("Or continue with", style: TextStyle(color: Colors.white70)),

                  const SizedBox(height: 40),

                  // Role-based Sign Up Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoleButton("User Signup", Icons.person_add, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MyMySignupPage(title: '')));
                      }),
                      _buildRoleButton("EV Signup", Icons.emergency, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EVSignupPage(title: '')));
                      }),
                    ],
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

  // Glassmorphic TextField
  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.amber),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.amber),
            onPressed: onToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  // Role Button
  Widget _buildRoleButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Your original login logic — unchanged
  void _send_data() async {
    String uname = _usernametextController.text.trim();
    String password = _passwordtextController.text;

    if (uname.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      if (url == null) {
        Fluttertoast.showToast(msg: "Server not configured");
        return;
      }

      final response = await http.post(
        Uri.parse('$url/user_login_post/'),
        body: {'uname': uname, 'password': password},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'ok') {
          String lid = jsonResponse['lid'].toString();
          String type = jsonResponse['type'].toString();
          await sh.setString("lid", lid);

          if (type == "Customer") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserProDashboard()));
          } else if (type == 'Emergency vehicle') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => evhome()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => tphome()));
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid credentials");
        }
      } else {
        Fluttertoast.showToast(msg: "Network error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}