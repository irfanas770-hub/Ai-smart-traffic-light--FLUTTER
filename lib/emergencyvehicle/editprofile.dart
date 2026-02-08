import 'dart:io';
import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ev_edit_profile(title: 'Edit Profile'),
  ));
}

class ev_edit_profile extends StatefulWidget {
  const ev_edit_profile({super.key, required this.title});
  final String title;

  @override
  State<ev_edit_profile> createState() => _ev_edit_profileState();
}

class _ev_edit_profileState extends State<ev_edit_profile>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  final TextEditingController typeController = TextEditingController();
  final TextEditingController vehiclenumberController = TextEditingController();
  final TextEditingController drivernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _selectedImage;
  String upic = "";
  String photo_ = "";

  // Unified Eye-Friendly Palette (same as all other screens)
  static const Color bgStart = Color(0xFF0D1B2A);
  static const Color bgEnd = Color(0xFF1B263B);
  static const Color accent = Color(0xFF4ECDC4);        // Soft calming teal
  static const Color accentDark = Color(0xFF3AB8B1);
  static const Color cardBg = Color(0xFF1E2A38);
  static const Color textMain = Color(0xFFE0E1DD);
  static const Color textMuted = Color(0xFF95A3B3);
  static const Color success = Color(0xFF95E1B0);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _get_data();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _get_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? img = sh.getString('img_url');

    if (url == null || lid == null || img == null) return;

    try {
      var response = await http.post(
        Uri.parse('$url/ev_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            typeController.text = json['type'] ?? '';
            vehiclenumberController.text = json['vehiclenumber'] ?? '';
            drivernameController.text = json['drivername'] ?? '';
            phoneController.text = json['phone'] ?? '';
            emailController.text = json['email'] ?? '';
            upic = img + (json['photo'] ?? '');
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile", backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    var status = await Permission.photos.request();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        photo_ = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    if (url == null || lid == null) return;

    var request = http.MultipartRequest('POST', Uri.parse('$url/ev_editprofile_post/'));
    request.fields.addAll({
      'lid': lid,
      'type': typeController.text,
      'vehiclenumber': vehiclenumberController.text,
      'drivername': drivernameController.text,
      'phone': phoneController.text,
      'email': emailController.text,
    });

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Profile Updated Successfully!",
          backgroundColor: success,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ev_view_profile(title: 'Profile')),
        );
      } else {
        Fluttertoast.showToast(msg: data['msg'] ?? "Update failed", backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error", backgroundColor: Colors.redAccent);
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
          "EDIT PROFILE",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 18),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
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
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Profile Photo with Gentle Teal Glow
                    GestureDetector(
                      onTap: _checkPermissionAndChooseImage,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.5 + 0.35 * _glowController.value),
                              blurRadius: 70,
                              spreadRadius: 25,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 90,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (upic.isNotEmpty ? NetworkImage(upic) : null),
                            child: _selectedImage == null && upic.isEmpty
                                ? Icon(Icons.camera_alt, size: 70, color: accent)
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "Tap to change photo",
                      style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 60),

                    // Modern Glassmorphic Input Fields
                    _glassField(controller: typeController, label: "Driver Type", icon: Icons.badge_outlined),
                    const SizedBox(height: 24),
                    _glassField(controller: vehiclenumberController, label: "Vehicle Number", icon: Icons.directions_car_filled_outlined),
                    const SizedBox(height: 24),
                    _glassField(controller: drivernameController, label: "Driver Name", icon: Icons.person_outline_rounded),
                    const SizedBox(height: 24),
                    _glassField(controller: phoneController, label: "Phone Number", icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                    const SizedBox(height: 24),
                    _glassField(controller: emailController, label: "Email Address", icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),

                    const SizedBox(height: 80),

                    // Glowing Save Button
                    GestureDetector(
                      onTap: _send_data,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 26),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(colors: [accent, accentDark]),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.6 + 0.3 * _glowController.value),
                              blurRadius: 55,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: textMain, fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMuted, fontSize: 16),
        prefixIcon: Icon(icon, color: accent, size: 26),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: accent.withOpacity(0.4), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: accent, width: 3),
        ),
      ),
    );
  }
}