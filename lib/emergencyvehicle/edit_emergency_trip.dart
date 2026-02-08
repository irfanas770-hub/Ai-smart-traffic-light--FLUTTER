import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/view_emergency_trip.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: edit_emergency_trip(title: 'Edit Emergency Trip'),
  ));
}

class edit_emergency_trip extends StatefulWidget {
  const edit_emergency_trip({super.key, required this.title});
  final String title;

  @override
  State<edit_emergency_trip> createState() => _edit_emergency_tripState();
}

class _edit_emergency_tripState extends State<edit_emergency_trip>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _datetextController = TextEditingController();
  final TextEditingController _timetextController = TextEditingController();
  final TextEditingController _destinationtextController = TextEditingController();

  late AnimationController _glowController;

  // Eye-Friendly & Professional Palette (same as home & trip list)
  static const Color bgStart = Color(0xFF0D1B2A);
  static const Color bgEnd = Color(0xFF1B263B);
  static const Color accent = Color(0xFF4ECDC4);        // Soft calming teal
  static const Color accentDark = Color(0xFF3AB8B1);
  static const Color cardBg = Color(0xFF1E2A38);
  static const Color textMain = Color(0xFFE0E1DD);
  static const Color textMuted = Color(0xFF95A3B3);
  static const Color success = Color(0xFF95E1B0);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _send_data();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? tid = sh.getString('tid');

    if (url == null || tid == null) {
      Fluttertoast.showToast(msg: "Session error", backgroundColor: Colors.redAccent);
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('$url/edit_emergency_trip_get/'),
        body: {'tid': tid},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            _datetextController.text = json['date'] ?? '';
            _timetextController.text = json['time'] ?? '';
            _destinationtextController.text = json['destination'] ?? '';
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load trip", backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _updateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? tid = sh.getString('tid');

    if (url == null || tid == null) {
      Fluttertoast.showToast(msg: "Session expired", backgroundColor: Colors.redAccent);
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$url/edit_emergency_trip_post/'));
    request.fields.addAll({
      'tid': tid,
      'date': _datetextController.text,
      'time': _timetextController.text,
      'destination': _destinationtextController.text,
    });

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Trip Updated Successfully!",
          backgroundColor: success,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => view_emergency_trip(title: '')),
        );
      } else {
        Fluttertoast.showToast(msg: "Update failed", backgroundColor: Colors.redAccent);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error", backgroundColor: Colors.redAccent);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: accent,
            onPrimary: Colors.black,
            surface: cardBg,
          ),
          dialogBackgroundColor: cardBg,
        ),
        child: child!,
      ),
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
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: accent,
            onPrimary: Colors.black,
          ),
        ),
        child: child!,
      ),
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
          "EDIT MISSION",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 18),
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
                      const SizedBox(height: 20),

                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.4 + 0.2 * _glowController.value),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit_location_alt_rounded, size: 80, color: accent),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        "MODIFY DISPATCH",
                        style: TextStyle(color: textMuted, fontSize: 16, letterSpacing: 6, fontWeight: FontWeight.w300),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Update Trip Details",
                        style: TextStyle(color: textMain, fontSize: 34, fontWeight: FontWeight.w900),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Glassmorphic Input Fields
                      _glassField(
                        controller: _datetextController,
                        label: "Mission Date",
                        icon: Icons.calendar_today_rounded,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 24),

                      _glassField(
                        controller: _timetextController,
                        label: "Departure Time",
                        icon: Icons.access_time_filled_rounded,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 24),

                      _glassField(
                        controller: _destinationtextController,
                        label: "Destination / Incident Location",
                        icon: Icons.location_on_rounded,
                        keyboardType: TextInputType.streetAddress,
                      ),

                      const SizedBox(height: 80),

                      // Glowing Update Button
                      GestureDetector(
                        onTap: _updateTrip,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(colors: [accent, accentDark]),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.6 + 0.3 * _glowController.value),
                                blurRadius: 50,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "UPDATE MISSION",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent.withOpacity(0.4), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: accent, width: 3),
        ),
        suffixIcon: onTap != null
            ? Icon(Icons.edit_calendar, color: accent.withOpacity(0.8))
            : null,
      ),
      validator: (v) => v!.trim().isEmpty ? "$label required" : null,
    );
  }
}