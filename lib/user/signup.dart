import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../login.dart';

void main() {
  runApp(const MyMySignup());
}

class MyMySignup extends StatelessWidget {
  const MyMySignup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Signup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins', // Optional: Add Google Fonts
      ),
      home: const MyMySignupPage(title: 'Create Account'),
    );
  }
}

class MyMySignupPage extends StatefulWidget {
  const MyMySignupPage({super.key, required this.title});
  final String title;

  @override
  State<MyMySignupPage> createState() => _MyMySignupPageState();
}

class _MyMySignupPageState extends State<MyMySignupPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String gender = "Male";
  File? _selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 20,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "Join Us Today",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Profile Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.deepPurple.shade100,
                            backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                            child: _selectedImage == null
                                ? const Icon(Icons.add_a_photo, size: 40, color: Colors.deepPurple)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Tap to add photo", style: TextStyle(color: Colors.grey)),

                        const SizedBox(height: 30),

                        // Form Fields
                        _buildTextField(nameController, "Full Name", Icons.person),
                        const SizedBox(height: 16),
                        _buildTextField(emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(phoneController, "Phone", Icons.phone, keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),

                        // DOB Picker
                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? dt = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(primary: Colors.deepPurple),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (dt != null) {
                              dobController.text = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                            labelText: "Date of Birth",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gender Selection
                        const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: "Male", label: Text("Male"), icon: Icon(Icons.male)),
                            ButtonSegment(value: "Female", label: Text("Female"), icon: Icon(Icons.female)),
                            ButtonSegment(value: "Other", label: Text("Other"), icon: Icon(Icons.transgender)),
                          ],
                          selected: {gender},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() => gender = newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            selectedBackgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(placeController, "Place", Icons.location_on),
                        const SizedBox(height: 16),
                        _buildTextField(pinController, "PIN Code", Icons.pin, keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(postController, "Post Office", Icons.local_post_office),
                        const SizedBox(height: 16),
                        _buildTextField(districtController, "District", Icons.map),

                        const SizedBox(height: 20),

                        // Password Fields
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            labelText: "Password",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmpasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.accessible_forward_outlined, color: Colors.deepPurple),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _send_data,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login"))),
                              child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _send_data() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Your existing upload logic here...
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      if (url == null) {
        Fluttertoast.showToast(msg: "Server URL not configured");
        setState(() => _isLoading = false);
        return;
      }

      final uri = Uri.parse('$url/user_signup_post/');
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'uname': nameController.text,
        'uemail': emailController.text,
        'uphone': phoneController.text,
        'udob': dobController.text,
        'ugender': gender,
        'uplace': placeController.text,
        'upin': pinController.text,
        'upost': postController.text,
        'udistrict': districtController.text,
        'upassword': passwordController.text,
        'uconfirmpassword': confirmpasswordController.text,
      });

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      try {
        var response = await request.send();
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);

        if (response.statusCode == 200 && data['status'] == 'ok') {
          Fluttertoast.showToast(msg: "Account created successfully!");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyLoginPage(title: "Login")));
        } else {
          Fluttertoast.showToast(msg: data['message'] ?? "Signup failed");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Network error: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    placeController.dispose();
    pinController.dispose();
    postController.dispose();
    districtController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }
}