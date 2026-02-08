import 'dart:convert';
import 'package:aismarttrafficlight/trafficpolice/tphome.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: add_trafficblock(title: 'Add Traffic Block'),
  ));
}

class add_trafficblock extends StatefulWidget {
  const add_trafficblock({super.key, required this.title});
  final String title;

  @override
  State<add_trafficblock> createState() => _add_trafficblockState();
}

class _add_trafficblockState extends State<add_trafficblock> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitBlock() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all fields correctly");
      return;
    }

    setState(() => _isLoading = true);

    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse('$url/add_trafficblock/'));
      request.fields.addAll({
        'lid': lid,
        'place': _placeController.text.trim(),
        'latitude': _latitudeController.text.trim(),
        'longitude': _longitudeController.text.trim(),
      });

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Traffic block added successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _placeController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const tphome()),
        );
      } else {
        Fluttertoast.showToast(msg: data['msg'] ?? "Failed to add block");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text("ADD TRAFFIC BLOCK"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Header Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A3D62).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.traffic,
                    size: 80,
                    color: Color(0xFF0A3D62),
                  ),
                ),

                const SizedBox(height: 32),
                const Text(
                  "Report Road Block",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Help keep roads safe by reporting traffic blocks",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),

                // Place Field
                _buildTextField(
                  controller: _placeController,
                  label: "Location / Place Name",
                  icon: Icons.location_on,
                  hint: "e.g. MG Road Junction",
                ),

                const SizedBox(height: 20),

                // Latitude Field
                _buildTextField(
                  controller: _latitudeController,
                  label: "Latitude",
                  icon: Icons.map_outlined,
                  hint: "e.g. 9.9816",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 20),

                // Longitude Field
                _buildTextField(
                  controller: _longitudeController,
                  label: "Longitude",
                  icon: Icons.map,
                  hint: "e.g. 76.2999",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 60),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A3D62),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      "SUBMIT BLOCK REPORT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF0A3D62)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF0A3D62), width: 2.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _placeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}