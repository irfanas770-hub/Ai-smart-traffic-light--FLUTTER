import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/edit_emergency_trip.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: view_emergency_trip(title: 'Emergency Trips'),
  ));
}

class view_emergency_trip extends StatefulWidget {
  const view_emergency_trip({super.key, required this.title});
  final String title;

  @override
  State<view_emergency_trip> createState() => _view_emergency_tripState();
}

class _view_emergency_tripState extends State<view_emergency_trip>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> trips = [];
  late AnimationController _glowController;

  // Eye-Friendly & Professional Color Scheme
  static const Color bgStart = Color(0xFF0D1B2A);
  static const Color bgEnd = Color(0xFF1B263B);
  static const Color accent = Color(0xFF4ECDC4);        // Soft teal-green (calm & trusted)
  static const Color accentDark = Color(0xFF3AB8B1);
  static const Color cardBg = Color(0xFF1E2A38);
  static const Color textMain = Color(0xFFE0E1DD);
  static const Color textMuted = Color(0xFF95A3B3);
  static const Color success = Color(0xFF95E1B0);
  static const Color danger = Color(0xFFE07A7A);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadTrips();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired", backgroundColor: danger);
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('$url/view_emergency_trip/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            trips = List<Map<String, dynamic>>.from(json['data']);
          });
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load trips", backgroundColor: danger);
    }
  }

  Future<void> _deleteTrip(String id) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) return;

    var request = http.MultipartRequest('POST', Uri.parse('$url/delete_emergency_trip/'));
    request.fields['id'] = id;

    try {
      var resp = await request.send();
      var data = jsonDecode(await resp.stream.bytesToString());
      if (resp.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Trip Deleted", backgroundColor: danger);
        _loadTrips();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Delete failed", backgroundColor: danger);
    }
  }

  Future<void> _updateStatus(String id) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) return;

    var request = http.MultipartRequest('POST', Uri.parse('$url/update_emergency_trip_status/'));
    request.fields['id'] = id;

    try {
      var resp = await request.send();
      var data = jsonDecode(await resp.stream.bytesToString());
      if (resp.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Trip Completed!", backgroundColor: success);
        _loadTrips();
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Update failed", backgroundColor: danger);
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
          "EMERGENCY DISPATCHES",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 18),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadTrips,
          ),
        ],
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
          child: trips.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emergency, size: 90, color: textMuted.withOpacity(0.6)),
                const SizedBox(height: 24),
                Text(
                  "No Trips Found",
                  style: TextStyle(color: textMuted, fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final bool isPending = trip['status'] == 'pending';

              return AnimatedBuilder(
                animation: _glowController,
                builder: (_, child) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      color: cardBg,
                      border: Border.all(
                        color: isPending ? accent.withOpacity(0.7) : Colors.white.withOpacity(0.12),
                        width: 2,
                      ),
                      boxShadow: isPending
                          ? [
                        BoxShadow(
                          color: accent.withOpacity(0.3 + 0.25 * _glowController.value),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon + Trip ID + Status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isPending ? accent : success.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emergency,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Trip ID: ${trip['id']}",
                              style: const TextStyle(
                                color: textMain,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPending ? accent.withOpacity(0.2) : success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isPending ? accent : success,
                                width: 1.8,
                              ),
                            ),
                            child: Text(
                              trip['status'].toUpperCase(),
                              style: TextStyle(
                                color: isPending ? accent : success,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Info Rows
                      _infoRow(Icons.calendar_today_rounded, "Date", trip['date']),
                      _infoRow(Icons.access_time_filled, "Time", trip['time']),
                      _infoRow(Icons.location_on_rounded, "Destination", trip['destination']),

                      const SizedBox(height: 28),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _actionButton(
                              label: "EDIT",
                              icon: Icons.edit_outlined,
                              color: accent,
                              onTap: () async {
                                SharedPreferences sh = await SharedPreferences.getInstance();
                                sh.setString('tid', trip['id'].toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => edit_emergency_trip(title: '')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _actionButton(
                              label: "DELETE",
                              icon: Icons.delete_forever_outlined,
                              color: danger,
                              onTap: () => _deleteTrip(trip['id'].toString()),
                            ),
                          ),
                        ],
                      ),

                      // Mark as Completed (only for pending)
                      if (isPending) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: _actionButton(
                            label: "MARK AS COMPLETED",
                            icon: Icons.check_circle,
                            color: success,
                            onTap: () => _updateStatus(trip['id'].toString()),
                          ),
                        ),
                      ],
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 24),
          const SizedBox(width: 16),
          Text("$label:", style: TextStyle(color: textMuted, fontSize: 15.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: textMain, fontSize: 16.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.7), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}