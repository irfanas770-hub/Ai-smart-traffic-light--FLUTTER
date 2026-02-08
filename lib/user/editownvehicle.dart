import 'dart:io';
import 'dart:convert';
import 'package:aismarttrafficlight/user/viewownvehicle.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class editownvehicle extends StatefulWidget {
  const editownvehicle({
    super.key,
    required this.title,
    required this.utype,
    required this.fueltype,
    required this.vehicleno,
    required this.lid,
    required this.photo,
  });

  final String title;
  final String utype;
  final String fueltype;
  final String vehicleno;
  final String photo;
  final String lid;

  @override
  State<editownvehicle> createState() => _editownvehicleState();
}

class _editownvehicleState extends State<editownvehicle> {
  // Eye-Friendly Light Theme Colors (Same as all other screens)
  static const Color bgStart = Color(0xFFE8F5FF);
  static const Color bgEnd = Color(0xFFF5F9FF);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF9BE5E0);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color success = Color(0xFF48BB78);
  static const Color shadowColor = Color(0x338EC8E6);

  late TextEditingController typeController;
  late TextEditingController fueltypeController;
  late TextEditingController vehiclenoController;

  File? _selectedImage;
  String up = "";

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController(text: widget.utype);
    fueltypeController = TextEditingController(text: widget.fueltype);
    vehiclenoController = TextEditingController(text: widget.vehicleno);
    up = widget.photo;
  }

  @override
  void dispose() {
    typeController.dispose();
    fueltypeController.dispose();
    vehiclenoController.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _sendData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/user_editownvehicle_post/');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll({
      'utype': typeController.text,
      'ufueltype': fueltypeController.text,
      'uvehicleno': vehiclenoController.text.trim().toUpperCase(),
      'id': widget.lid,
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
          msg: "Vehicle updated successfully!",
          backgroundColor: success,
          textColor: Colors.white,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ViewOwnVehiclesPage()),
              (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Update failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textMain,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: 1),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(color: shadowColor, blurRadius: 30, offset: const Offset(0, 15)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Edit Vehicle Details",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textMain),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Update your vehicle information",
                    style: TextStyle(color: textMuted, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Vehicle Photo
                  GestureDetector(
                    onTap: _chooseImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accent, width: 4),
                        boxShadow: [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 20)],
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: accentLight.withOpacity(0.3),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (up.isNotEmpty ? NetworkImage(up) : null),
                        child: _selectedImage == null && up.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_rounded, size: 64, color: accent),
                            const SizedBox(height: 8),
                            Text("Tap to change", style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.bold)),
                          ],
                        )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedImage != null ? "New photo selected" : "Tap image to change",
                    style: TextStyle(color: _selectedImage != null ? success : textMuted, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 40),

                  // Vehicle Type
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: "Vehicle Type",
                      prefixIcon: Icon(Icons.category_rounded, color: accent),
                      filled: true,
                      fillColor: accent.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: accent.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: accent, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fuel Type
                  TextField(
                    controller: fueltypeController,
                    decoration: InputDecoration(
                      labelText: "Fuel Type",
                      prefixIcon: Icon(Icons.local_gas_station_rounded, color: accent),
                      filled: true,
                      fillColor: accent.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: accent.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: accent, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Number
                  TextField(
                    controller: vehiclenoController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: "Vehicle Number",
                      hintText: "e.g. KL-07-BB-1234",
                      prefixIcon: Icon(Icons.confirmation_number_rounded, color: accent),
                      filled: true,
                      fillColor: accent.withOpacity(0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: accent.withOpacity(0.4))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: accent, width: 2)),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _sendData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shadowColor: accent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 1.5),
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