import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import '../login.dart';
import 'userchangepassword.dart';
import 'addownvehicle.dart';
import 'view_evtrip.dart';
import 'viewnearbynotification.dart';
import 'viewnearbytsalert.dart';
import 'viewownvehicle.dart';
import 'viewpaidlogs.dart';
import 'viewprofile.dart';
import 'viewsignal.dart';

void main() {
  runApp(const UserProDashboardApp());
}

class UserProDashboardApp extends StatelessWidget {
  const UserProDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Smart Traffic Pro',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF4ECDC4),
          secondary: const Color(0xFF6EE2D9),
          surface: Colors.white,
          background: const Color(0xFFF5F9FF),
        ),
      ),
      home: const UserProDashboard(),
    );
  }
}

void callbackDispatcher(String message) {
  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
  var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var settings = InitializationSettings(android: android);
  flip.initialize(settings);
  _showNotificationWithDefaultSound(flip, message);
}

Future _showNotificationWithDefaultSound(flip, String message) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'alert_channel', 'Traffic Alerts',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flip.show(0, 'Incoming Alert', message, platformChannelSpecifics);
}

class UserProDashboard extends StatefulWidget {
  const UserProDashboard({super.key});

  @override
  State<UserProDashboard> createState() => _UserProDashboardState();
}

class _UserProDashboardState extends State<UserProDashboard> {
  String name_ = "User";
  String photo_ = "https://via.placeholder.com/150";
  bool isLoading = true;
  Timer? _t;

  // Eye-Friendly Light Theme Colors
  static const Color bgStart = Color(0xFFE8F5FF);
  static const Color bgEnd = Color(0xFFF5F9FF);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentLight = Color(0xFF9BE5E0);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFF6AD55);
  static const Color shadowColor = Color(0x338EC8E6);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _t = Timer.periodic(const Duration(seconds: 10), (timer) => getdata());
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> getdata() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    Location location = Location();
    try {
      LocationData userLocation = await location.getLocation();
      String url = sh.getString('url').toString();
      final urls = Uri.parse('$url/viewevalertnotif/');
      String nid = sh.getString('nid') ?? "0";

      var datas = await http.post(urls, body: {
        'nid': nid,
        'user_lon': userLocation.longitude.toString(),
        'user_lat': userLocation.latitude.toString(),
      });

      var jsondata = json.decode(datas.body);
      if (jsondata['status'] == "ok") {
        String message = jsondata['message'];
        String latitude = jsondata['latitude'].toString();
        String longitude = jsondata['longitude'].toString();
        sh.setString('nid', jsondata['nid'].toString());

        double userLat = userLocation.latitude!;
        double userLon = userLocation.longitude!;
        double servLat = double.parse(latitude);
        double servLon = double.parse(longitude);

        double distance = calculateDistance(userLat, userLon, servLat, servLon);
        if (distance <= 1.0) {
          callbackDispatcher(message);
        }
      }
    } catch (e) {
      print("Alert Error: $e");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    var dLat = _deg2rad(lat2 - lat1);
    var dLon = _deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? imgUrl = sh.getString('img_url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) return;

      final response = await http.post(
        Uri.parse('$url/user_viewprofile_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            name_ = data['name'] ?? "User";
            photo_ = (imgUrl ?? "") + (data['photo'] ?? "");
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Logout", style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to logout?", style: TextStyle(color: textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel", style: TextStyle(color: accent, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences sh = await SharedPreferences.getInstance();
      await sh.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyLoginPage(title: '')),
            (route) => false,
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
        foregroundColor: textMain,
        title: const Text("DASHBOARD", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: accent), onPressed: _loadProfile),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        elevation: 12,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehiclePage())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: accent, strokeWidth: 4))
              : SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Profile Card
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 4)),
                          child: CircleAvatar(radius: 70, backgroundImage: NetworkImage(photo_), backgroundColor: accentLight.withOpacity(0.3)),
                        ),
                        const SizedBox(height: 20),
                        Text(name_, style: const TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text("Smart Driver • Verified", style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.star, color: accent, size: 22),
                            const SizedBox(width: 8),
                            Text("PRO USER", style: TextStyle(color: accent, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
                const Padding(padding: EdgeInsets.only(left: 28), child: Text("Quick Access", style: TextStyle(color: textMain, fontSize: 21, fontWeight: FontWeight.bold))),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _quickChip("My Vehicles", Icons.directions_car_filled_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewOwnVehiclesPage()))),
                      _quickChip("Traffic Signals", Icons.traffic_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewsignal(title: '')))),
                      _quickChip("Nearby Alerts", Icons.notification_important_rounded, warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewnearbynotification(title: '')))),
                      _quickChip("Emergency Alert", Icons.emergency, Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyTrafficSignalsPremium()))),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                const Padding(padding: EdgeInsets.only(left: 28), child: Text("Analytics", style: TextStyle(color: textMain, fontSize: 21, fontWeight: FontWeight.bold))),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      _statCard("Vehicles", "3", Icons.electric_car_rounded, accent),
                      const SizedBox(width: 16),
                      _statCard("Alerts", "7", Icons.warning_amber_rounded, warning),
                      const SizedBox(width: 16),
                      _statCard("Paid", "₹1,240", Icons.payments_rounded, success),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                const Padding(padding: EdgeInsets.only(left: 28), child: Text("Main Menu", style: TextStyle(color: textMain, fontSize: 21, fontWeight: FontWeight.bold))),
                const SizedBox(height: 16),

                // FIXED: No more overflow!
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: 1.15, // Reduced from 1.3 → Perfect fit
                    children: [
                      _menuCard("EV Trip History", Icons.history_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const view_evtrip(title: '')))),
                      _menuCard("Emergency Alert", Icons.emergency, Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyTrafficSignalsPremium()))),
                      _menuCard("Payment Logs", Icons.receipt_long_rounded, success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewpaidlogs(title: '')))),
                      _menuCard("Add Vehicle", Icons.add_circle_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehiclePage()))),
                      _menuCard("All Alerts", Icons.notifications_active_rounded, warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewnearbynotification(title: '')))),
                      _menuCard("Change Password", Icons.lock_reset_rounded, accentLight, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
                      _menuCard("My Profile", Icons.person_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ViewProfilePage()))),
                      _menuCard("Traffic Signals", Icons.traffic_rounded, accent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const viewsignal(title: '')))),
                    ],
                  ),
                ),
                const SizedBox(height: 80), // Extra bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: textMain, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: textMuted, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 22, offset: const Offset(0, 10))],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: textMain, fontSize: 14.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}