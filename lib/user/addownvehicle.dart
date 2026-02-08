import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'viewownvehicle.dart';

void main() {
  runApp(const AddVehicleApp());
}

class AddVehicleApp extends StatelessWidget {
  const AddVehicleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Add Vehicle',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4ECDC4),
          secondary: Color(0xFF6EE2D9),
        ),
      ),
      home: const AddVehiclePage(),
    );
  }
}

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;

  String selectedType = "Car";
  String selectedFuel = "Petrol";

  final TextEditingController vehicleNoController = TextEditingController();

  final List<String> vehicleTypes = ["Bike", "E-Rickshaw", "Car", "Truck"];
  final List<String> fuelTypes = ["Petrol", "Diesel", "Electric", "CNG", "LPG"];

  // Eye-Friendly Light Theme Colors (Same as Dashboard)
  static const Color bgStart = Color(0xFFE8F5FF);
  static const Color bgEnd = Color(0xFFF5F9FF);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF9BE5E0);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color success = Color(0xFF48BB78);
  static const Color shadowColor = Color(0x338EC8E6);

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textMain,
        title: const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21, letterSpacing: 1)),
        centerTitle: true,
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
          child: Center(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header
                      const Text(
                        "Register Your Vehicle",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textMain),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Add vehicle details to get smart alerts",
                        style: TextStyle(color: textMuted, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Vehicle Photo Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 4),
                            boxShadow: [
                              BoxShadow(color: accent.withOpacity(0.3), blurRadius: 20),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: accentLight.withOpacity(0.3),
                            backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                            child: _selectedImage == null
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car_rounded, size: 64, color: accent),
                                const SizedBox(height: 8),
                                Text("Tap to upload", style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.bold)),
                              ],
                            )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedImage != null ? "Photo Selected" : "Upload Vehicle Photo",
                        style: TextStyle(
                          color: _selectedImage != null ? success : textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Vehicle Type - Segmented Button
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Vehicle Type", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textMain)),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<String>(
                        segments: vehicleTypes.map((type) {
                          IconData icon;
                          switch (type) {
                            case "Bike":
                              icon = Icons.two_wheeler_rounded;
                              break;
                            case "E-Rickshaw":
                              icon = Icons.electric_rickshaw_rounded;
                              break;
                            case "Car":
                              icon = Icons.directions_car_rounded;
                              break;
                            case "Truck":
                              icon = Icons.local_shipping_rounded;
                              break;
                            default:
                              icon = Icons.directions_car_rounded;
                          }
                          return ButtonSegment(
                            value: type,
                            label: Text(type, style: const TextStyle(fontSize: 13)),
                            icon: Icon(icon, size: 20),
                          );
                        }).toList(),
                        selected: {selectedType},
                        onSelectionChanged: (newSelection) {
                          setState(() => selectedType = newSelection.first);
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: accent.withOpacity(0.1),
                          selectedBackgroundColor: accent,
                          foregroundColor: accent,
                          selectedForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Fuel Type Dropdown
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Fuel Type", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textMain)),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedFuel,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.local_gas_station_rounded, color: accent),
                          filled: true,
                          fillColor: accent.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: accent.withOpacity(0.4)),
                          ),
                        ),
                        dropdownColor: cardBg,
                        items: fuelTypes
                            .map((fuel) => DropdownMenuItem(value: fuel, child: Text(fuel)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedFuel = value!),
                      ),

                      const SizedBox(height: 32),

                      // Vehicle Number
                      TextFormField(
                        controller: vehicleNoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Vehicle Number",
                          hintText: "e.g. KL-07-BB-1234",
                          prefixIcon: Icon(Icons.confirmation_number_rounded, color: accent),
                          filled: true,
                          fillColor: accent.withOpacity(0.08),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: accent.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: accent, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return "Vehicle number required";
                          if (value.length < 5) return "Enter valid number";
                          return null;
                        },
                      ),

                      const SizedBox(height: 50),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addVehicle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 15,
                            shadowColor: accent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : const Text("Add Vehicle", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? lid = sh.getString('lid');

      var request = http.MultipartRequest('POST', Uri.parse('$url/user_addownvehicle_post/'));

      request.fields.addAll({
        'lid': lid.toString(),
        'utype': selectedType,
        'ufueltype': selectedFuel,
        'uvehicleno': vehicleNoController.text.trim().toUpperCase(),
      });

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Vehicle added successfully!", backgroundColor: success);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ViewOwnVehiclesPage()),
        );
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Failed to add vehicle");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    vehicleNoController.dispose();
    super.dispose();
  }
}