import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: tpviewprofile(title: 'My Profile'),
  ));
}

class tpviewprofile extends StatefulWidget {
  const tpviewprofile({super.key, required this.title});
  final String title;

  @override
  State<tpviewprofile> createState() => _tpviewprofileState();
}

class _tpviewprofileState extends State<tpviewprofile> {
  String photo_ = "";
  String number_ = "";
  String email_ = "";
  String station_ = "";
  String proof_ = "";

  @override
  void initState() {
    super.initState();
    _send_data();
  }

  void _send_data() async {
    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');
    final img = sh.getString('img_url');

    if (url == null || lid == null || img == null) {
      Fluttertoast.showToast(msg: "Session expired");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/tp_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            number_ = json['number'] ?? 'N/A';
            email_ = json['email'] ?? 'N/A';
            station_ = json['station'] ?? 'Traffic Police Station';
            proof_ = img + (json['proof'] ?? '');
            photo_ = img + (json['photo'] ?? '');
          });
        } else {
          Fluttertoast.showToast(msg: "Profile not found");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  Future<void> _openProof() async {
    if (proof_.isEmpty ) {
      Fluttertoast.showToast(msg: "No document available");
      return;
    }
    final uri = Uri.parse(proof_);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Cannot open document");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text("MY PROFILE"),
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Officer Photo
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[300],
                backgroundImage: photo_.isNotEmpty ? NetworkImage(photo_) : null,
                child: photo_.isEmpty
                    ? const Icon(Icons.security, size: 90, color: Color(0xFF0A3D62))
                    : null,
              ),

              const SizedBox(height: 30),

              // Station Name - Big & Bold
              Text(
                station_,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D62),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Traffic Police Officer",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              // Profile Info Cards
              _buildInfoCard(Icons.phone_android, "Contact Number", number_),
              const SizedBox(height: 16),
              _buildInfoCard(Icons.email_outlined, "Email Address", email_),
              const SizedBox(height: 16),
              _buildInfoCard(Icons.location_city, "Police Station", station_),

              const SizedBox(height: 50),

              // View Proof Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openProof,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 28),
                  label: const Text(
                    "VIEW ID PROOF / DOCUMENT",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D62),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A3D62).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0A3D62), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}