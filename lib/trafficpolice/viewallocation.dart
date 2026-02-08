import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: viewallocation(title: 'My Allocations'),
  ));
}

class viewallocation extends StatefulWidget {
  const viewallocation({super.key, required this.title});
  final String title;

  @override
  State<viewallocation> createState() => _viewallocationState();
}

class _viewallocationState extends State<viewallocation> {
  List<Map<String, dynamic>> allocations = [];

  @override
  void initState() {
    super.initState();
    _loadAllocations();
  }

  Future<void> _loadAllocations() async {
    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/tp_view_allocation/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            allocations = List<Map<String, dynamic>>.from(json['data']);
          });
        } else {
          Fluttertoast.showToast(msg: "No allocations found");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text("MY DUTY ALLOCATIONS"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllocations,
          ),
        ],
      ),
      body: allocations.isEmpty
          ? const Center(
        child: Text(
          "No duty allocations found",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allocations.length,
        itemBuilder: (context, index) {
          final alloc = allocations[index];
          final isActive = alloc['status'].toLowerCase() == 'active';

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: isActive
                      ? [const Color(0xFF0A3D62).withOpacity(0.05), Colors.white]
                      : [Colors.grey.withOpacity(0.05), Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Date & Status
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: isActive ? const Color(0xFF0A3D62) : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          alloc['date'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A3D62),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Text(
                            alloc['status'].toUpperCase(),
                            style: TextStyle(
                              color: isActive ? Colors.green[700] : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    // Details
                    _detailRow(Icons.access_time, "Time", alloc['time']),
                    _detailRow(Icons.traffic, "Traffic Junction", alloc['trafficjunction']),
                    _detailRow(Icons.location_on, "Location", "${alloc['latitude']}, ${alloc['longitude']}"),

                    const SizedBox(height: 16),

                    // Fine Amount (if any)
                    if (alloc['fine'] != null && alloc['fine'].toString().isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3D62).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_money, color: Color(0xFF0A3D62)),
                            const SizedBox(width: 10),
                            const Text(
                              "Fine Collected:",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              "₹${alloc['fine']}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A3D62),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A3D62), size: 22),
          const SizedBox(width: 14),
          Text(
            "$label:",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}