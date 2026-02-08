import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      home: viewnearbynotification(title: 'Notifications'),
    );
  }
}

class viewnearbynotification extends StatefulWidget {
  const viewnearbynotification({super.key, required this.title});
  final String title;

  @override
  State<viewnearbynotification> createState() => _viewnearbynotificationState();
}

class _viewnearbynotificationState extends State<viewnearbynotification>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    viewnearbynotification("");
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> viewnearbynotification(String searchValue) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/user_viewnearby_notification_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'date': item['date'] ?? 'Unknown Date',
            'message': item['message'] ?? 'No message',
          });
        }

        // Sort by latest first
        tempList.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));

        setState(() {
          users = tempList;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Failed to load notifications");
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_pulseController),
              child: const Icon(Icons.refresh_rounded, size: 26),
            ),
            onPressed: () => viewnearbynotification(""),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1A0559), Color(0xFF6A11CB)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () => viewnearbynotification(""),
            color: Colors.cyanAccent,
            strokeWidth: 3,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Transform(
                    transform: Matrix4.rotationZ(index.isEven ? -0.03 : 0.03),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.6),
                            blurRadius: 25,
                            spreadRadius: 3,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Pulsating Alert Icon
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, child) {
                                    return Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.orange.withOpacity(0.9),
                                            Colors.orange.withOpacity(0.2),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(0.8 * _pulseController.value),
                                            blurRadius: 40,
                                            spreadRadius: 18,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.notifications_active,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),

                                // Notification Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['message'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_filled,
                                            size: 18,
                                            color: Colors.cyanAccent,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            user['date'],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // New Badge (for recent ones)
                                if (index < 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "NEW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 7,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 120,
            color: Colors.white24,
          ),
          const SizedBox(height: 30),
          const Text(
            "No Notifications",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You're all caught up!\nPull down to check again",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}