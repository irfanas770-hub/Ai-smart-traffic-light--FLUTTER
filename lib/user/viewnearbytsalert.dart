import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PremiumNearbyTSApp());
}

class PremiumNearbyTSApp extends StatelessWidget {
  const PremiumNearbyTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Traffic Pro',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const NearbyTrafficSignalsPremium(),
    );
  }
}

class NearbyTrafficSignalsPremium extends StatefulWidget {
  const NearbyTrafficSignalsPremium({super.key});

  @override
  State<NearbyTrafficSignalsPremium> createState() => _NearbyTrafficSignalsPremiumState();
}

class _NearbyTrafficSignalsPremiumState extends State<NearbyTrafficSignalsPremium>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> signals = [];
  bool isLoading = true;
  late AnimationController _pulseController;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _refreshController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _loadSignals();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadSignals() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      if (url == null) {
        Fluttertoast.showToast(msg: "Server URL missing");
        setState(() => isLoading = false);
        return;
      }

      var response = await http.post(
        Uri.parse('$url/user_viewnearby_TS_alert_post/'),
        body: {},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'ok') {
          List<Map<String, dynamic>> temp = [];
          for (var item in data['data']) {
            double lat = double.tryParse(item['latitude'].toString()) ?? 0.0;
            double lng = double.tryParse(item['longitude'].toString()) ?? 0.0;
            double distance = _calculateDistance(lat, lng);

            temp.add({
              'id': item['id'].toString(),
              'name': item['signalname'] ?? 'Traffic Signal',
              'lat': lat,
              'lng': lng,
              'distance': distance,
            });
          }

          temp.sort((a, b) => a['distance'].compareTo(b['distance']));

          setState(() {
            signals = temp;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Connection failed");
    }
  }

  double _calculateDistance(double lat, double lng) {
    const userLat = 9.9312;
    const userLng = 76.2673;
    double dx = (lat - userLat).abs();
    double dy = (lng - userLng).abs();
    return math.sqrt(dx * dx + dy * dy) * 111;
  }

  String _formatDistance(double km) {
    if (km < 1) return "${(km * 1000).toStringAsFixed(0)} m";
    return "${km.toStringAsFixed(1)} km";
  }

  void _openMaps(double lat, double lng) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
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
        title: const Text("Nearby Signals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _refreshController.forward(from: 0.0);
              _loadSignals();
            },
            icon: RotationTransition(
              turns: _refreshController,
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0B3D), Color(0xFF1A0559), Color(0xFF6A11CB)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : signals.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: _loadSignals,
            color: Colors.cyan,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: signals.length,
              itemBuilder: (context, index) {
                final s = signals[index];
                final distance = s['distance'] as double;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Transform(
                    transform: Matrix4.rotationZ(index.isEven ? -0.03 : 0.03),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.7),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                            ),
                            child: Row(
                              children: [
                                // Pulsating Traffic Light
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (_, child) {
                                    return Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.red.withOpacity(0.8),
                                            Colors.red.withOpacity(0.3),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.9 * _pulseController.value),
                                            blurRadius: 40,
                                            spreadRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.traffic, size: 48, color: Colors.white),
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.cyan),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${s['lat'].toStringAsFixed(5)}, ${s['lng'].toStringAsFixed(5)}",
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.near_me,
                                            size: 22,
                                            color: distance < 1 ? Colors.greenAccent : Colors.orangeAccent,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDistance(distance),
                                            style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: distance < 1 ? Colors.greenAccent : Colors.orangeAccent,
                                            ),
                                          ),
                                          const Text(" away", style: TextStyle(color: Colors.white60)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // GO Button
                                GestureDetector(
                                  onTap: () => _openMaps(s['lat'], s['lng']),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00D4FF), Color(0xFF3A7BD5)],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6))
                                      ],
                                    ),
                                    child: const Column(
                                      children: [
                                        Icon(Icons.navigation, color: Colors.white, size: 32),
                                        SizedBox(height: 4),
                                        Text("GO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
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
          Icon(Icons.traffic_rounded, size: 130, color: Colors.white24),
          const SizedBox(height: 30),
          const Text(
            "All Clear!",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            "No traffic signals nearby.\nEnjoy your smooth drive!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}