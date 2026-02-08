import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../login.dart';

void main() {
  runApp(const MyEVApp());
}

class MyEVApp extends StatelessWidget {
  const MyEVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EV Driver Registration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C853)), // Green for EV
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const EVSignupPage(title: 'EV Driver Registration'),
    );
  }
}

class EVSignupPage extends StatefulWidget {
  const EVSignupPage({super.key, required this.title});
  final String title;

  @override
  State<EVSignupPage> createState() => _EVSignupPageState();
}

class _EVSignupPageState extends State<EVSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;

  final TextEditingController typeController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Optional: Predefined EV types
  String selectedEVType = "E-Rickshaw";

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    } else {
      Fluttertoast.showToast(msg: "No image selected");
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
              Color(0xFF00C853), // Bright Green
              Color(0xFF1DE9B6), // Teal Green
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black38,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Title
                        Text(
                          "EV Driver Registration",
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF006400),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Join the Green Revolution",
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                        const SizedBox(height: 30),

                        // Vehicle/Driver Photo
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.green.shade100,
                            backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                            child: _selectedImage == null
                                ? const Icon(Icons.electric_car, size: 60, color: Colors.green)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Tap to upload vehicle/driver photo",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),

                        // Vehicle Type (Segmented Button - Premium Touch)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Vehicle Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: "E-Ambulance", label: Text("Ambulance"), icon: Icon(Icons.warning_amber)),
                            ButtonSegment(value: "E-Fire", label:Text("Fire"), icon: Icon(Icons.fire_extinguisher_rounded)),

                          ],
                          selected: {selectedEVType},
                          onSelectionChanged: (newSelection) {
                            setState(() => selectedEVType = newSelection.first);
                            typeController.text = selectedEVType;
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            selectedBackgroundColor: Colors.green,
                            foregroundColor: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Fields
                        _buildField(vehicleNumberController, "Vehicle Number", Icons.directions_car, TextInputType.text),
                        const SizedBox(height: 16),
                        _buildField(driverNameController, "Driver Name", Icons.person),
                        const SizedBox(height: 16),
                        _buildField(phoneController, "Phone Number", Icons.phone, TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildField(emailController, "Email Address", Icons.email, TextInputType.emailAddress),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006400),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 10,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Register Now",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login")));
                          },
                          child: const Text(
                            "Already registered? Login here",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: label.contains("Name") || label.contains("Vehicle") ? TextCapitalization.words : TextCapitalization.none,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        labelText: label,
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }

  void _sendData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found!");
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$url/ev_signup_post/');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'evtype': selectedEVType,
      'evvehiclenumber': vehicleNumberController.text.trim(),
      'evdrivername': driverNameController.text.trim(),
      'evphone': phoneController.text.trim(),
      'evemail': emailController.text.trim(),
    });

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "EV Driver Registered Successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login")),
        );
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Registration failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    typeController.dispose();
    vehicleNumberController.dispose();
    driverNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}