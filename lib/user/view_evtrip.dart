import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: view_evtrip(title: 'Emergency Trips'),
    );
  }
}

class view_evtrip extends StatefulWidget {
  const view_evtrip({super.key, required this.title});
  final String title;

  @override
  State<view_evtrip> createState() => _view_evtripState();
}

class _view_evtripState extends State<view_evtrip>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    view_evtrip("");
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> view_evtrip(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/user_viewevtrip/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'photo': img + item['photo'],
            'time': item['time'],
            'vehiclenumber': item['vehiclenumber'],
            'date': item['date'],
            'status': item['status'],
            'destination': item['destination'],
          });
        }
        setState(() {
          users = tempList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load trips")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23, letterSpacing: 1),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () => view_evtrip(""),
            color: Colors.cyan,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isActive = user['status'].toString().toLowerCase() == 'active';

                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, index.isEven ? 8 : -8),
                      child: Opacity(
                        opacity: 0.9 + (_pulseController.value * 0.1),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTripCard(user, isActive),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> user, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                color: isActive ? Colors.redAccent.withOpacity(0.7) : Colors.white.withOpacity(0.3),
                width: isActive ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? Colors.red.withOpacity(0.6)
                      : Colors.cyan.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Pulsating Siren Icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: isActive
                                  ? [
                                Colors.red.withOpacity(0.9),
                                Colors.red.withOpacity(0.1),
                              ]
                                  : [
                                Colors.blue.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isActive
                                    ? Colors.red.withOpacity(0.8 * _pulseController.value)
                                    : Colors.cyan.withOpacity(0.6 * _pulseController.value),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      backgroundImage: NetworkImage(user['photo']),
                    ),
                    if (isActive)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.emergency, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 18),

                // Trip Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['vehiclenumber'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _detailRow(Icons.location_on, "To", user['destination'], Colors.cyanAccent),
                      _detailRow(Icons.access_time, "Time", user['time'], Colors.amberAccent),
                      _detailRow(Icons.calendar_today, "Date", user['date'], Colors.white70),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.red.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? Colors.redAccent : Colors.greenAccent,
                            width: 1.8,
                          ),
                        ),
                        child: Text(
                          user['status'].toUpperCase(),
                          style: TextStyle(
                            color: isActive ? Colors.redAccent : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Icon
                Icon(
                  isActive ? Icons.directions_car : Icons.check_circle,
                  size: 50,
                  color: isActive ? Colors.redAccent : Colors.greenAccent,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            "$label:",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emergency, size: 110, color: Colors.white24),
          const SizedBox(height: 30),
          const Text(
            "No Active Trips",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            "Pull down to refresh",
            style: TextStyle(color: Colors.white60, fontSize: 16),
          ),
        ],
      ),
    );
  }
}