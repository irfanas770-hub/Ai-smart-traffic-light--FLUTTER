import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:aismarttrafficlight/emergencyvehicle/evchangepassword.dart';
import 'package:aismarttrafficlight/emergencyvehicle/view_emergency_trip.dart';
import 'package:aismarttrafficlight/emergencyvehicle/viewprofile.dart';
import 'package:aismarttrafficlight/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_emergencytrip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFF121826),
      ),
      home: const evhome(),
    );
  }
}

class evhome extends StatefulWidget {
  const evhome({super.key});
  @override
  State<evhome> createState() => _evhomeState();
}

class _evhomeState extends State<evhome> with TickerProviderStateMixin {
  Timer? _t;
  late AnimationController _glowController;

  String type_ = "";
  String vehiclenumber_ = "";
  String drivername_ = "";
  String photo_ = "";

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _send_data();
    _t = Timer.periodic(const Duration(seconds: 10), (_) => getLocation());
  }

  @override
  void dispose() {
    _t?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  Location location = Location();

  Future<void> getLocation() async {
    if (await location.requestPermission() != PermissionStatus.granted) return;
    try {
      LocationData loc = await location.getLocation();
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? lid = sh.getString('lid');
      if (url == null || lid == null) return;

      var req = http.MultipartRequest('POST', Uri.parse('$url/updateloc/'));
      req.fields.addAll({'lid': lid, 'lat': loc.latitude.toString(), 'long': loc.longitude.toString()});
      await req.send();
    } catch (_) {}
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String img_url = sh.getString('img_url') ?? '';
    String lid = sh.getString('lid') ?? '';

    final response = await http.post(Uri.parse('$url/ev_viewprofile_post/'), body: {'lid': lid});
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['status'] == 'ok') {
        setState(() {
          type_ = json['type'] ?? 'Officer';
          vehiclenumber_ = json['vehiclenumber'] ?? 'EV-001';
          drivername_ = json['drivername'] ?? 'Emergency Driver';
          photo_ = img_url + (json['photo'] ?? '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("EV COMMAND CENTER", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 4, fontSize: 18)),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121826), Color(0xFF1C2538)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            children: [
              const SizedBox(height: 30),

              // Avatar with Soft Teal Glow
              Center(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (_, child) {
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.3 + 0.2 * _glowController.value),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4ECDC4), width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      backgroundImage: photo_.isNotEmpty ? NetworkImage(photo_) : null,
                      child: photo_.isEmpty
                          ? const Icon(Icons.security, size: 90, color: Color(0xFF4ECDC4))
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text("HELLO,", textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 18, letterSpacing: 3)),
              const SizedBox(height: 8),
              Text(drivername_, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
              Text("$type_ • $vehiclenumber_", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 60),

              // Clean Modern Buttons
              _modernButton("START EMERGENCY TRIP", Icons.emergency, const Color(0xFF26A69A), () => Navigator.push(context, MaterialPageRoute(builder: (_) => add_emergencytrip(title: '')))),
              _modernButton("VIEW PROFILE", Icons.person_outline, const Color(0xFF4ECDC4), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ev_view_profile(title: '')))),
              _modernButton("TRIP HISTORY", Icons.history, const Color(0xFF4ECDC4), () => Navigator.push(context, MaterialPageRoute(builder: (_) => view_emergency_trip(title: '')))),
              _modernButton("CHANGE PASSWORD", Icons.lock_outline, const Color(0xFF4ECDC4), () => Navigator.push(context, MaterialPageRoute(builder: (_) => evchangepassword(title: '')))),

              const SizedBox(height: 60),

              // Live Location Status
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF4ECDC4), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.my_location, color: Color(0xFF4ECDC4), size: 24),
                      SizedBox(width: 12),
                      Text("LIVE TRACKING ACTIVE", style: TextStyle(color: Color(0xFF4ECDC4), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Logout
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _t?.cancel();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => MyLoginPage(title: '')), (r) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white60),
                  label: const Text("Logout", style: TextStyle(color: Colors.white60, fontSize: 17)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernButton(String title, IconData icon, Color accentColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}