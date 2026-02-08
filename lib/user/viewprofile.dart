import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editprofile.dart';

void main() {
  runApp(const ViewProfileApp());
}

class ViewProfileApp extends StatelessWidget {
  const ViewProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const ViewProfilePage(),
    );
  }
}

class ViewProfilePage extends StatefulWidget {
  const ViewProfilePage({super.key});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  bool _isLoading = true;
  bool _hasError = false;

  String name_ = "";
  String email_ = "";
  String phone_ = "";
  String dob_ = "";
  String gender_ = "";
  String place_ = "";
  String pin_ = "";
  String post_ = "";
  String district_ = "";
  String photo_ = "https://via.placeholder.com/150"; // fallback

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? imgUrl = sh.getString('img_url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) {
        throw Exception("Login session expired");
      }

      final response = await http.post(
        Uri.parse('$url/user_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            name_ = data['name'] ?? "N/A";
            email_ = data['email'] ?? "N/A";
            phone_ = data['phone'] ?? "N/A";
            dob_ = data['dob'] ?? "N/A";
            gender_ = data['gender'] ?? "N/A";
            place_ = data['place'] ?? "N/A";
            pin_ = data['pin'] ?? "N/A";
            post_ = data['post'] ?? "N/A";
            district_ = data['district'] ?? "N/A";
            photo_ = (imgUrl ?? "") + (data['photo'] ?? "");
            _isLoading = false;
          });
        } else {
          throw Exception("Profile not found");
        }
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.white70),
                const SizedBox(height: 20),
                const Text("Failed to load profile", style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Profile Header
                Card(
                  elevation: 20,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Photo
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.deepPurple.shade100,
                          backgroundImage: NetworkImage(photo_),
                          onBackgroundImageError: (_, __) {
                            setState(() => photo_ = "https://via.placeholder.com/150");
                          },
                          child: photo_.isEmpty
                              ? const Icon(Icons.person, size: 80, color: Colors.deepPurple)
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Name & Email
                        Text(
                          name_,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email_,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        // Info Grid
                        _buildInfoRow("Phone", phone_, Icons.phone),
                        _buildInfoRow("Date of Birth", dob_, Icons.cake),
                        _buildInfoRow("Gender", gender_, gender_ == "Male" ? Icons.male : Icons.female),
                        _buildInfoRow("Place", place_, Icons.home),
                        _buildInfoRow("PIN Code", pin_, Icons.pin),
                        _buildInfoRow("Post Office", post_, Icons.local_post_office),
                        _buildInfoRow("District", district_, Icons.location_city),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Floating Edit Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 28),
                    label: const Text("Edit Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isLoading || _hasError
          ? null
          : FloatingActionButton(
        onPressed: _fetchProfile,
        backgroundColor: Colors.white,
        child: const Icon(Icons.refresh, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple.shade600, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}