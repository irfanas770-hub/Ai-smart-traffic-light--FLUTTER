import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/view_emergency_trip.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: add_emergencytrip(title: 'Add Emergency Trip'),
  ));
}

class add_emergencytrip extends StatefulWidget {
  const add_emergencytrip({super.key, required this.title});
  final String title;

  @override
  State<add_emergencytrip> createState() => _add_emergencytripState();
}

class _add_emergencytripState extends State<add_emergencytrip>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _datetextController = TextEditingController();
  final TextEditingController _timetextController = TextEditingController();
  final TextEditingController _destinationtextController = TextEditingController();

  late AnimationController _glowController;

  // Unified Eye-Friendly Palette (same as all other screens)
  static const Color bgStart = Color(0xFF0D1B2A);
  static const Color bgEnd = Color(0xFF1B263B);
  static const Color accent = Color(0xFF4ECDC4);        // Soft calming teal
  static const Color accentDark = Color(0xFF3AB8B1);
  static const Color textMain = Color(0xFFE0E1DD);
  static const Color textMuted = Color(0xFF95A3B3);
  static const Color success = Color(0xFF95E1B0);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _sendData() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fill all fields", backgroundColor: Colors.redAccent);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired", backgroundColor: Colors.redAccent);
      return;
    }

    final uri = Uri.parse('$url/ev_add_emergency_trip_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll({
      'date': _datetextController.text,
      'time': _timetextController.text,
      'destination': _destinationtextController.text,
      'lid': lid,
    });

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Emergency Trip Added!",
          backgroundColor: success,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => view_emergency_trip(title: '')),
        );
      } else {
        Fluttertoast.showToast(msg: data['msg'] ?? "Failed to add trip", backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error", backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accent,
              onPrimary: Colors.black,
              surface: bgEnd,
            ),
            dialogBackgroundColor: bgEnd,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _datetextController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: accent,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timetextController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ADD EMERGENCY TRIP",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 18),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgEnd],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Header Icon with Gentle Glow
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.4 + 0.25 * _glowController.value),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(Icons.emergency, size: 80, color: accent),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "INITIATE MISSION",
                        style: TextStyle(color: textMuted, fontSize: 16, letterSpacing: 6, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Emergency Dispatch",
                        style: TextStyle(color: textMain, fontSize: 34, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 70),

                      // Glassmorphic Input Fields
                      _glassField(
                        controller: _datetextController,
                        label: "Mission Date",
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 26),

                      _glassField(
                        controller: _timetextController,
                        label: "Departure Time",
                        icon: Icons.access_time_filled_rounded,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 26),

                      _glassField(
                        controller: _destinationtextController,
                        label: "Destination / Incident Location",
                        icon: Icons.location_on_rounded,
                        keyboardType: TextInputType.streetAddress,
                      ),

                      const SizedBox(height: 90),

                      // Glowing Dispatch Button
                      GestureDetector(
                        onTap: _sendData,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(colors: [accent, accentDark]),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.6 + 0.3 * _glowController.value),
                                blurRadius: 60,
                                spreadRadius: 22,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "DISPATCH NOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(color: textMain, fontSize: 17),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textMuted, fontSize: 16),
        prefixIcon: Icon(icon, color: accent, size: 26),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accent.withOpacity(0.4), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: accent, width: 3),
        ),
        suffixIcon: onTap != null
            ? Icon(Icons.arrow_drop_down_rounded, color: accent.withOpacity(0.8))
            : null,
      ),
      validator: (value) => value!.trim().isEmpty ? "$label is required" : null,
    );
  }
}