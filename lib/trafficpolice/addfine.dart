import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: addfine(title: 'Add Fine'),
  ));
}

class addfine extends StatefulWidget {
  const addfine({super.key, required this.title});
  final String title;

  @override
  State<addfine> createState() => _addfineState();
}

class _addfineState extends State<addfine> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fineController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF1E3A8A)),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1E3A8A)),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      Fluttertoast.showToast(msg: "Please select a photo of the violation");
      return;
    }

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? vid = sh.getString('vid');

      if (url == null || vid == null) {
        Fluttertoast.showToast(msg: "Session error. Please login again.");
        return;
      }

      final uri = Uri.parse('$url/tp_add_fine_post/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['ufine'] = _fineController.text.trim();
      request.fields['vid'] = vid;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      var response = await request.send();
      var data = jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Fine added successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context); // Go back after success
      } else {
        Fluttertoast.showToast(msg: "Failed to add fine", backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2C5282),
                Colors.white,
              ],
              stops: [0.0, 0.4, 0.9],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long, size: 70, color: Colors.amber),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Issue New Fine",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  // Image Picker
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 60, color: Color(0xFF1E3A8A)),
                          SizedBox(height: 12),
                          Text("Tap to add photo of violation", style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Fine Amount Field
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: TextFormField(
                        controller: _fineController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Fine Amount (₹)",
                          prefixText: "₹ ",
                          prefixStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          border: InputBorder.none,
                          icon: Icon(Icons.monetization_on, color: Color(0xFF1E3A8A)),
                        ),
                        style: const TextStyle(fontSize: 18),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Enter fine amount";
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return "Enter a valid amount";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black54)
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 26),
                          SizedBox(width: 12),
                          Text("Issue Fine", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}