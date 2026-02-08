import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/evhome.dart';
import 'package:aismarttrafficlight/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: evchangepassword(title: ''),
  ));
}

class evchangepassword extends StatefulWidget {
  const evchangepassword({super.key, required this.title});
  final String title;

  @override
  State<evchangepassword> createState() => _evchangepasswordState();
}

class _evchangepasswordState extends State<evchangepassword>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordtextController = TextEditingController();
  final TextEditingController _newpasswordtextController = TextEditingController();
  final TextEditingController _confirmpasswortextController = TextEditingController();

  late AnimationController _glowController;

  // Eye-friendly, calming color palette (2025 standard)
  static const Color bgTop = Color(0xFF0D1117);     // True dark (easy on eyes)
  static const Color bgBottom = Color(0xFF080B10);
  static const Color accent = Color(0xFF94D6C3);    // Soft mint green – ultra calming
  static const Color accentDark = Color(0xFF6AB8A3);
  static const Color glass = Color(0xFF1E293B);
  static const Color softWhite = Color(0xFFE2EEEA);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true); // Slow, gentle pulse
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
      return;
    }

    String password = _passwordtextController.text.trim();
    String newpassword = _newpasswordtextController.text.trim();
    String confirmpassword = _confirmpasswortextController.text.trim();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired. Please login again.");
      return;
    }

    final uri = Uri.parse('$url/ev_changepassword/');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll({
      'password': password,
      'newpassword': newpassword,
      'confirmpassword': confirmpassword,
      'lid': lid,
    });

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Password changed successfully!",
          backgroundColor: accentDark,
          textColor: Colors.white,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MyLoginPage(title: '')),
              (route) => false,
        );
      } else {
        Fluttertoast.showToast(
          msg: data['msg'] ?? "Failed to change password",
          backgroundColor: Colors.red[800],
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CHANGE PASSWORD",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 2.5,
            fontSize: 18,
            color: softWhite,
          ),
        ),
        centerTitle: true,
        foregroundColor: softWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: softWhite),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const evhome()),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Text(
                        "SECURE YOUR ACCOUNT",
                        style: TextStyle(
                          color: softWhite.withOpacity(0.7),
                          fontSize: 16,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Update Password",
                        style: TextStyle(
                          color: softWhite,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: accent.withOpacity(0.35),
                              blurRadius: 25,
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 70),

                      _glassInputField(
                        controller: _passwordtextController,
                        label: "Current Password",
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 26),
                      _glassInputField(
                        controller: _newpasswordtextController,
                        label: "New Password",
                        icon: Icons.vpn_key_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 26),
                      _glassInputField(
                        controller: _confirmpasswortextController,
                        label: "Confirm New Password",
                        icon: Icons.check_circle_outline_rounded,
                        obscureText: true,
                        validator: (value) {
                          if (value != _newpasswordtextController.text) {
                            return "Passwords do not match";
                          }
                          if (value == null || value.isEmpty) {
                            return "Confirm password required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 80),

                      // Calm, elegant button with gentle glow
                      GestureDetector(
                        onTap: _sendData,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [accent, accentDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.3 + 0.2 * _glowController.value),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "UPDATE PASSWORD",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: softWhite.withOpacity(0.8), fontSize: 15),
        prefixIcon: Icon(icon, color: accent, size: 23),
        filled: true,
        fillColor: glass,
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accent, width: 2.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
        ),
      ),
      validator: validator ??
              (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
    );
  }
}