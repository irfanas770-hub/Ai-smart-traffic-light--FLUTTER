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
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewsignal(title: 'View Signals'),
    );
  }
}

class viewsignal extends StatefulWidget {
  const viewsignal({super.key, required this.title});
  final String title;

  @override
  State<viewsignal> createState() => _viewsignalState();
}

class _viewsignalState extends State<viewsignal> with TickerProviderStateMixin {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    viewsignal(""); // Load signals
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> viewsignal(String searchValue) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      String apiUrl = '$urls/user_viewsignal/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid,
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          double lat = double.tryParse(item['latitude'].toString()) ?? 0.0;
          double lng = double.tryParse(item['longitude'].toString()) ?? 0.0;
          double distance = _calculateDistance(lat, lng);

          tempList.add({
            'latitude': lat,
            'longitude': lng,
            'signalname': item['signalname'] ?? 'Unknown Signal',
            'distance': distance,
          });
        }

        // Sort by nearest first
        tempList.sort((a, b) => a['distance'].compareTo(b['distance']));

        setState(() {
          users = tempList;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Connection failed");
    }
  }

  double _calculateDistance(double lat, double lng) {
    const double userLat = 9.9312; // Mock current location
    const double userLng = 76.2673;
    double dx = (lat - userLat).abs();
    double dy = (lng - userLng).abs();
    return math.sqrt(dx * dx + dy * dy) * 111; // Approx km
  }

  String _formatDistance(double km) {
    if (km < 1) return "${(km * 1000).toStringAsFixed(0)} m";
    return "${km.toStringAsFixed(1)} km";
  }

  void _openMaps(double lat, double lng) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse("google.navigation:q=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(Uri.parse("https://maps.google.com/?q=$lat,$lng"));
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
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_pulseController),
              child: const Icon(Icons.refresh_rounded),
            ),
            onPressed: () => viewsignal(""),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0B3D), Color(0xFF1A0559), Color(0xFF6A11CB)],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? _buildShimmer()
              : users.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: () => viewsignal(""),
            color: Colors.cyan,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final distance = user['distance'] as double;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8), // Prevents edge overflow
                    child: Transform(
                      transform: Matrix4.rotationZ(index.isEven ? -0.03 : 0.03),
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
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
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(18), // Reduced a bit for safety
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  // Pulsating Icon
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (_, child) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(colors: [
                                            Colors.red.withOpacity(0.9),
                                            Colors.red.withOpacity(0.2),
                                          ]),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.8 * _pulseController.value),
                                              blurRadius: 30,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.traffic, size: 40, color: Colors.white),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),

                                  // Info Column - Now wrapped in Expanded + IntrinsicWidth to prevent overflow
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['signalname'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Lat: ${user['latitude'].toStringAsFixed(6)}",
                                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                                        ),
                                        Text(
                                          "Lng: ${user['longitude'].toStringAsFixed(6)}",
                                          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.near_me,
                                                size: 18,
                                                color: distance < 1 ? Colors.greenAccent : Colors.orangeAccent),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatDistance(distance),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: distance < 1 ? Colors.greenAccent : Colors.orangeAccent,
                                              ),
                                            ),
                                            const Text(" away", style: TextStyle(color: Colors.white60, fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Navigate Button - Fixed size
                                  GestureDetector(
                                    onTap: () => _openMaps(user['latitude'], user['longitude']),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)]),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
                                        ],
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.navigation, color: Colors.white, size: 26),
                                          SizedBox(height: 4),
                                          Text("GO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
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
          Icon(Icons.traffic, size: 120, color: Colors.white24),
          const SizedBox(height: 30),
          const Text(
            "No Signals Found",
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