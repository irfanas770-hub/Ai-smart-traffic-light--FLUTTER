import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: view_trafficblock(title: 'Traffic Blocks'),
  ));
}

class view_trafficblock extends StatefulWidget {
  const view_trafficblock({super.key, required this.title});
  final String title;

  @override
  State<view_trafficblock> createState() => _view_trafficblockState();
}

class _view_trafficblockState extends State<view_trafficblock> {
  List<Map<String, dynamic>> blocks = [];

  @override
  void initState() {
    super.initState();
    _loadTrafficBlocks();
  }

  Future<void> _loadTrafficBlocks() async {
    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');
    final lid = sh.getString('lid');

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Session expired");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/view_trafficblock/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'ok') {
          setState(() {
            blocks = List<Map<String, dynamic>>.from(json['data']);
          });
        } else {
          Fluttertoast.showToast(msg: "No blocks found");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Network error");
    }
  }

  Future<void> _deleteBlock(String blockId) async {
    final sh = await SharedPreferences.getInstance();
    final url = sh.getString('url');

    if (url == null) return;

    try {
      final response = await http.post(
        Uri.parse('$url/Delete_traffic_block_get/'),
        body: {'id': blockId},
      );

      final json = jsonDecode(response.body);
      if (json['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Block removed successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _loadTrafficBlocks(); // Refresh list
      } else {
        Fluttertoast.showToast(msg: "Failed to delete");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting block");
    }
  }

  void _confirmDelete(Map<String, dynamic> block) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text("Confirm Delete"),
          ],
        ),
        content: Text("Remove traffic block at:\n\n${block['place']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBlock(block['id'].toString());
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps(String lat, String lng) async {
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A3D62),
        foregroundColor: Colors.white,
        title: const Text("TRAFFIC BLOCKS"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTrafficBlocks,
          ),
        ],
      ),
      body: blocks.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.traffic, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "No Traffic Blocks Reported",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          final block = blocks[index];

          return Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A3D62).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.location_on, color: Color(0xFF0A3D62), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            block['place'] ?? 'Unknown Location',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0A3D62)),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    _locationRow(icon: Icons.map_outlined, label: "Latitude", value: block['latitude'] ?? 'N/A'),
                    const SizedBox(height: 12),
                    _locationRow(icon: Icons.map, label: "Longitude", value: block['longitude'] ?? 'N/A'),

                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // View on Map Button
                        TextButton.icon(
                          onPressed: () {
                            final lat = block['latitude'];
                            final lng = block['longitude'];
                            if (lat != null && lng != null) {
                              _openInMaps(lat.toString(), lng.toString());
                            }
                          },
                          icon: const Icon(Icons.directions, color: Color(0xFF0A3D62)),
                          label: const Text("View on Map", style: TextStyle(color: Color(0xFF0A3D62), fontWeight: FontWeight.bold)),
                        ),

                        const SizedBox(width: 12),

                        // Delete Button
                        ElevatedButton.icon(
                          onPressed: () => _confirmDelete(block),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
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

  Widget _locationRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0A3D62), size: 24),
        const SizedBox(width: 14),
        Text("$label:", style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
          ),
        ),
      ],
    );
  }
}