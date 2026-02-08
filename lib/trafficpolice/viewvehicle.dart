import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'addfine.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: viewvehicle(title: 'Registered Vehicles'),
  ));
}

class viewvehicle extends StatefulWidget {
  const viewvehicle({super.key, required this.title});
  final String title;

  @override
  State<viewvehicle> createState() => _viewvehicleState();
}

class _viewvehicleState extends State<viewvehicle> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewvehicle("");
  }

  Future<void> viewvehicle(String searchValue) async {
    setState(() => isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/tp_viewvehicle_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'Photo': img + (item['photo'] ?? ''),
            'id': item['id'],
            'Type': item['type'] ?? 'Unknown',
            'Fuel Type': item['fueltype'] ?? 'N/A',
            'Vehicle No': item['vehiclenumber'] ?? 'N/A',
          });
        }
        setState(() {
          users = tempList;
        });
      } else {
        Fluttertoast.showToast(msg: "No vehicles found", backgroundColor: Colors.grey[800]);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load vehicles", backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Registered Vehicles",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF2C5282),
                Colors.white,
              ],
              stops: [0.0, 0.35, 0.8],
            ),
          ),
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 4),
          )
              : users.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, size: 90, color: Colors.white70),
                const SizedBox(height: 20),
                const Text(
                  "No Vehicles Found",
                  style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "No registered vehicles at the moment",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: () => viewvehicle(""),
            color: Colors.amber,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final vehicle = users[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Vehicle Photo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            vehicle['Photo'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle['Vehicle No'],
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.category, size: 10, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(vehicle['Type'], style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.local_gas_station, size: 10, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(vehicle['Fuel Type'], style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Issue Fine Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            SharedPreferences sh = await SharedPreferences.getInstance();
                            await sh.setString("vid", vehicle['id'].toString());
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const addfine(title: 'Issue Fine'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 20),
                          label: const Text("Fine", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                        ),
                      ],
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
}