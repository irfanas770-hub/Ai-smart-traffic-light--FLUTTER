import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editprofile.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ev_view_profile(title: 'View Profile'),
  ));
}

class ev_view_profile extends StatefulWidget {
  const ev_view_profile({super.key, required this.title});
  final String title;

  @override
  State<ev_view_profile> createState() => _ev_view_profileState();
}

class _ev_view_profileState extends State<ev_view_profile>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  String type_ = "Loading...";
  String vehiclenumber_ = "";
  String drivername_ = "Emergency Driver";
  String phone_ = "";
  String email_ = "";
  String photo_ = "https://via.placeholder.com/150";

  // Unified Eye-Friendly Palette (same as all other screens)
  static const Color bgStart = Color(0xFF0D1B2A);
  static const Color bgEnd = Color(0xFF1B263B);
  static const Color accent = Color(0xFF4ECDC4);        // Soft calming teal
  static const Color accentDark = Color(0xFF3AB8B1);
  static const Color cardBg = Color(0xFF1E2A38);
  static const Color textMain = Color(0xFFE0E1DD);
  static const Color textMuted = Color(0xFF95A3B3);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _send_data();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? img = sh.getString('img_url');

    if (url == null || lid == null || img == null) {
      Fluttertoast.showToast(msg: "Session error", backgroundColor: Colors.redAccent);
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('$url/ev_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            type_ = json['type'] ?? 'Driver';
            vehiclenumber_ = json['vehiclenumber'] ?? 'N/A';
            drivername_ = json['drivername'] ?? 'Emergency Driver';
            phone_ = json['phone'] ?? 'N/A';
            email_ = json['email'] ?? 'N/A';
            photo_ = img + (json['photo'] ?? '');
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile", backgroundColor: Colors.redAccent);
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
          "MY PROFILE",
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

                    // Glowing Avatar with Soft Teal Glow
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.4 + 0.3 * _glowController.value),
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
                            backgroundImage: NetworkImage(photo_),
                            child: photo_.contains("placeholder")
                                ? Icon(Icons.local_police, size: 100, color: accent)
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Driver Name
                    Text(
                      drivername_,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textMain,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "$type_ • $vehiclenumber_",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accent,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Profile Info Cards (Modern Glassmorphic Style)
                    _infoCard(Icons.badge_outlined, "Driver Type", type_),
                    _infoCard(Icons.directions_car_filled_outlined, "Vehicle Number", vehiclenumber_),
                    _infoCard(Icons.phone_android_rounded, "Phone", phone_),
                    _infoCard(Icons.email_rounded, "Email", email_),

                    const SizedBox(height: 70),

                    // Edit Profile Button with Gentle Glow
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ev_edit_profile(title: "Edit Profile")),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(colors: [accent, accentDark]),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.6 + 0.3 * _glowController.value),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "EDIT PROFILE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
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

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: textMuted, fontSize: 15, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(color: textMain, fontSize: 19, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}