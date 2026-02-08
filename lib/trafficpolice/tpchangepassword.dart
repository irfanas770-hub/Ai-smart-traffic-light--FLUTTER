import 'dart:convert';
import 'package:aismarttrafficlight/login.dart';
import 'package:aismarttrafficlight/trafficpolice/tphome.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: tpchangepassword(title: 'Change Password'),
  ));
}

class tpchangepassword extends StatefulWidget {
  const tpchangepassword({super.key, required this.title});
  final String title;

  @override
  State<tpchangepassword> createState() => _tpchangepasswordState();
}

class _tpchangepasswordState extends State<tpchangepassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordtextController = TextEditingController();
  final TextEditingController _newpasswordtextController = TextEditingController();
  final TextEditingController _confirmpasswortextController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
      return;
    }

    if (_newpasswordtextController.text != _confirmpasswortextController.text) {
      Fluttertoast.showToast(msg: "New password and confirm password do not match");
      return;
    }

    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired");
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$url/tpchangepassword/'));
    request.fields.addAll({
      'lid': lid,
      'password': _passwordtextController.text,
      'newpassword': _newpasswordtextController.text,
      'confirmpassword': _confirmpasswortextController.text,
    });

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Password changed successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MyLoginPage(title: '')),
              (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: data['msg'] ?? "Failed to change password");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text("CHANGE PASSWORD"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Security Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3D62).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 80,
                    color: Color(0xFF0A3D62),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Secure Your Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your current password and choose a new one",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),

                // Old Password
                _buildPasswordField(
                  controller: _passwordtextController,
                  label: "Current Password",
                  obscure: _obscureOld,
                  onToggle: () => setState(() => _obscureOld = !_obscureOld),
                ),

                const SizedBox(height: 20),

                // New Password
                _buildPasswordField(
                  controller: _newpasswordtextController,
                  label: "New Password",
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),

                const SizedBox(height: 20),

                // Confirm Password
                _buildPasswordField(
                  controller: _confirmpasswortextController,
                  label: "Confirm New Password",
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),

                const SizedBox(height: 50),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3D62),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      "UPDATE PASSWORD",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF0A3D62)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0A3D62), width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value
            .trim()
            .isEmpty) return "$label is required";
        //   if (value.length < 5) return "Password must be at least 6 characters";
        //   return null;
        // },
      }
    );
  }

  @override
  void dispose() {
    _passwordtextController.dispose();
    _newpasswordtextController.dispose();
    _confirmpasswortextController.dispose();
    super.dispose();
  }
}