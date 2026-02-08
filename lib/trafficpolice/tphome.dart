import 'dart:convert';
import 'package:aismarttrafficlight/login.dart';
import 'package:aismarttrafficlight/trafficpolice/add_trafficblock.dart';
import 'package:aismarttrafficlight/trafficpolice/addnotification.dart';
import 'package:aismarttrafficlight/trafficpolice/tpchangepassword.dart';
import 'package:aismarttrafficlight/trafficpolice/view_trafficblock.dart';
import 'package:aismarttrafficlight/trafficpolice/viewallocation.dart';
import 'package:aismarttrafficlight/trafficpolice/viewfine.dart';
import 'package:aismarttrafficlight/trafficpolice/viewnotification.dart';
import 'package:aismarttrafficlight/trafficpolice/viewprofile.dart';
import 'package:aismarttrafficlight/trafficpolice/viewvehicle.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'addfine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traffic Police',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A3D62),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const tphome(),
    );
  }
}

class tphome extends StatefulWidget {
  const tphome({super.key});

  @override
  State<tphome> createState() => _tphomeState();
}

class _tphomeState extends State<tphome> {
  String photo_ = "";
  String station_ = "Traffic Officer";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');
    final img = sh.getString('img_url');

    if (url == null || lid == null || img == null) return;

    try {
      final response = await http.post(
        Uri.parse('$url/tp_viewprofile_post/'),
        body: {'lid': lid},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            station_ = json['station'] ?? 'Traffic Police Station';
            photo_ = img + (json['photo'] ?? '');
          });
        }
      }
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TRAFFIC POLICE"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Section
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: photo_.isNotEmpty ? NetworkImage(photo_) : null,
                child: photo_.isEmpty
                    ? const Icon(Icons.security, size: 70, color: Color(0xFF0A3D62))
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome back,",
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                station_,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D62),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Action Grid - Eye-Friendly Cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _menuCard("View vehicle", Icons.receipt_long, () => Navigator.push(context, MaterialPageRoute(builder: (_) => viewvehicle(title: '')))),
                  _menuCard("Add Notification", Icons.notification_add, () => Navigator.push(context, MaterialPageRoute(builder: (_) => addnotificaion(title: '')))),
                  _menuCard("View Fines", Icons.format_list_bulleted, () => Navigator.push(context, MaterialPageRoute(builder: (_) => viewfine(title: '')))),
                  _menuCard("View Notifications", Icons.campaign, () => Navigator.push(context, MaterialPageRoute(builder: (_) => tp_viewnotification(title: '')))),
                  _menuCard("Add Block", Icons.block, () => Navigator.push(context, MaterialPageRoute(builder: (_) => add_trafficblock(title: '')))),
                  _menuCard("View Blocks", Icons.traffic, () => Navigator.push(context, MaterialPageRoute(builder: (_) => view_trafficblock(title: '')))),
                  _menuCard("Allocations", Icons.how_to_reg, () => Navigator.push(context, MaterialPageRoute(builder: (_) => viewallocation(title: '')))),
                  _menuCard("My Profile", Icons.person_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => tpviewprofile(title: '')))),
                  _menuCard("Change Password", Icons.lock_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => tpchangepassword(title: '')))),
                ],
              ),

              const SizedBox(height: 50),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyLoginPage(title: '')),
                          (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "LOGOUT",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.42,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Icon(icon, size: 50, color: const Color(0xFF0A3D62)),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
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