import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'viewprofile.dart';

void main() {
  runApp(const EditProfileApp());
}

class EditProfileApp extends StatelessWidget {
  const EditProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Edit Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;
  String _currentPhoto = '';
  String gender = "Male";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? imgUrl = sh.getString('img_url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) {
        Fluttertoast.showToast(msg: "Session expired");
        return;
      }

      final response = await http.post(
        Uri.parse('$url/user_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phone'] ?? '';
            dobController.text = data['dob'] ?? '';
            gender = data['gender'] ?? 'Male';
            placeController.text = data['place'] ?? '';
            pinController.text = data['pin'] ?? '';
            postController.text = data['post'] ?? '';
            districtController.text = data['district'] ?? '';
            _currentPhoto = (imgUrl ?? '') + (data['photo'] ?? '');
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile");
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 20,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Edit Profile",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Photo
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.deepPurple.shade100,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (_currentPhoto.isNotEmpty
                              ? NetworkImage(_currentPhoto) as ImageProvider
                              : const AssetImage("assets/placeholder.png")),
                          child: _selectedImage == null && _currentPhoto.isEmpty
                              ? const Icon(Icons.camera_alt, size: 50, color: Colors.deepPurple)
                              : Stack(
                            children: [
                              if (_selectedImage != null)
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green, width: 4),
                                  ),
                                ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.deepPurple,
                                  child: Icon(Icons.edit, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Tap to change photo", style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 30),

                      // Form Fields
                      _buildField(nameController, "Full Name", Icons.person),
                      const SizedBox(height: 16),
                      _buildField(emailController, "Email", Icons.email, readOnly: true),
                      const SizedBox(height: 16),
                      _buildField(phoneController, "Phone", Icons.phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),

                      // DOB
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? dt = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.deepPurple)),
                              child: child!,
                            ),
                          );
                          if (dt != null) {
                            dobController.text = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
                          }
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                          labelText: "Date of Birth",
                          filled: true,
                          fillColor: Colors.deepPurple.shade50,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gender
                      const Align(alignment: Alignment.centerLeft, child: Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 10),
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
                        style: SegmentedButton.styleFrom(backgroundColor: Colors.deepPurple.shade50, selectedBackgroundColor: Colors.deepPurple),
                      ),
                      const SizedBox(height: 20),

                      _buildField(placeController, "Place", Icons.home),
                      const SizedBox(height: 16),
                      _buildField(pinController, "PIN Code", Icons.pin, keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildField(postController, "Post Office", Icons.local_post_office),
                      const SizedBox(height: 16),
                      _buildField(districtController, "District", Icons.location_city),

                      const SizedBox(height: 40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        labelText: label,
        filled: true,
        fillColor: Colors.deepPurple.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.deepPurple.shade200)),
      ),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? lid = sh.getString('lid');

      var request = http.MultipartRequest('POST', Uri.parse('$url/user_editprofile_post/'));

      request.fields.addAll({
        'lid': lid.toString(),
        'uname': nameController.text,
        'uemail': emailController.text,
        'uphone': phoneController.text,
        'udob': dobController.text,
        'ugender': gender,
        'uplace': placeController.text,
        'upin': pinController.text,
        'upost': postController.text,
        'udistrict': districtController.text,
      });

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Profile updated successfully!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ViewProfilePage()));
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Update failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
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
    super.dispose();
  }
}