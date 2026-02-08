import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'editownvehicle.dart';
import 'viewfineentryandpay.dart';
import 'addownvehicle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Vehicles',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4ECDC4),
          secondary: Color(0xFF6EE2D9),
        ),
      ),
      home: const ViewOwnVehiclesPage(),
    );
  }
}

class ViewOwnVehiclesPage extends StatefulWidget {
  const ViewOwnVehiclesPage({super.key});

  @override
  State<ViewOwnVehiclesPage> createState() => _ViewOwnVehiclesPageState();
}

class _ViewOwnVehiclesPageState extends State<ViewOwnVehiclesPage> {
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;

  // Eye-Friendly Light Theme Colors (Same as Dashboard)
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
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? imgUrl = sh.getString('img_url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) {
        Fluttertoast.showToast(msg: "Session expired");
        return;
      }

      var response = await http.post(
        Uri.parse('$url/user_viewownvehicle_post/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          List<Map<String, dynamic>> temp = [];
          for (var item in jsonData['data']) {
            temp.add({
              'id': item['id'],
              'photo': (imgUrl ?? '') + (item['photo'] ?? ''),
              'type': item['type'] ?? 'Unknown',
              'fueltype': item['fueltype'] ?? 'N/A',
              'vehicleno': item['vehiclenumber'] ?? 'N/A',
            });
          }
          setState(() {
            vehicles = temp;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  Future<void> _deleteVehicle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Delete Vehicle", style: TextStyle(color: textMain, fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to remove this vehicle?", style: TextStyle(color: textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel", style: TextStyle(color: accent))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      var request = http.MultipartRequest('POST', Uri.parse('$url/delete_ownvehicle/'));
      request.fields['id'] = id;

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Vehicle deleted", backgroundColor: success);
        _loadVehicles();
      } else {
        Fluttertoast.showToast(msg: "Failed to delete");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
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
        title: const Text("My Vehicles", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 21)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: accent), onPressed: _loadVehicles),
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
              : vehicles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: _loadVehicles,
            color: accent,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Dismissible(
                  key: Key(vehicle['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 30),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 36),
                  ),
                  onDismissed: (_) => _deleteVehicle(vehicle['id'].toString()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: shadowColor, blurRadius: 20, offset: const Offset(0, 10))],
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          vehicle['photo'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: accent.withOpacity(0.2),
                            child: Icon(Icons.directions_car_rounded, size: 50, color: accent),
                          ),
                        ),
                      ),
                      title: Text(
                        vehicle['vehicleno'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textMain),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _infoRow(Icons.category_rounded, "Type", vehicle['type']),
                          const SizedBox(height: 6),
                          _infoRow(Icons.local_gas_station_rounded, "Fuel", vehicle['fueltype']),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _actionButton("Edit", Icons.edit_rounded, accent, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => editownvehicle(
                                      title: "Edit Vehicle",
                                      utype: vehicle['type'],
                                      fueltype: vehicle['fueltype'],
                                      vehicleno: vehicle['vehicleno'],
                                      lid: vehicle['id'].toString(),
                                      photo: vehicle['photo'],
                                    ),
                                  ),
                                ).then((_) => _loadVehicles());
                              }),
                              const SizedBox(width: 14),
                              _actionButton("Fines & Pay", Icons.receipt_long_rounded, success, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ViewFineEntryPage(id: vehicle['id'].toString())),
                                );
                              }),
                            ],
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_rounded, size: 110, color: accent.withOpacity(0.6)),
          const SizedBox(height: 24),
          const Text(
            "No vehicles found",
            style: TextStyle(fontSize: 24, color: textMain, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text("Tap the + button to add your first vehicle", style: TextStyle(color: textMuted, fontSize: 16)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehiclePage())),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accent),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, color: textMain)),
        Text(value, style: TextStyle(color: textMuted)),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}