import 'dart:convert';
import 'package:flutter/material.dart';
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
      home: viewfine(title: 'My Fines'),
    );
  }
}

class viewfine extends StatefulWidget {
  const viewfine({super.key, required this.title});
  final String title;

  @override
  State<viewfine> createState() => _viewfineState();
}

class _viewfineState extends State<viewfine> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    viewfine("");
  }

  Future<void> viewfine(String searchValue) async {
    setState(() => isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/tp_viewfine_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'photo': img + (item['photo'] ?? ''),
            'id': item['id'],
            'fine': item['fine'] ?? '0',
            'date': item['date'] ?? '-',
            'time': item['time'] ?? '-',
            'status': item['status'] ?? 'Pending',
            'vehiclenumber': item['vehiclenumber'] ?? 'N/A',
          });
        }
        setState(() {
          users = tempList;
        });
      } else {
        Fluttertoast.showToast(
          msg: "No fines found",
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load fines",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    String s = status.toLowerCase();
    if (s.contains("paid")) return Colors.green;
    if (s.contains("pending")) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A8A), // Deep Navy
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "My Traffic Fines",
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
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 4,
            ),
          )
              : users.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                const Text(
                  "No Fines Found",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "You have a clean driving record!",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: () => viewfine(""),
            color: Colors.amber,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final fine = users[index];

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            fine['photo'],
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
                                fine['vehiclenumber'],
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("Fine Amount: ₹${fine['fine']}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              Text("${fine['date']} • ${fine['time']}", style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.circle, size: 14, color: _getStatusColor(fine['status'])),
                                  const SizedBox(width: 8),
                                  Text(
                                    fine['status'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(fine['status']),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Button
                        // if (fine['status'].toString().toLowerCase().contains('pending'))
                        //   ElevatedButton.icon(
                        //     onPressed: () async {
                        //       SharedPreferences sh = await SharedPreferences.getInstance();
                        //       await sh.setString("fine_id", fine['id'].toString());
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => const viewfineentryandpay(title: "Pay Fine"),
                        //         ),
                        //       );
                        //     },
                        //     icon: const Icon(Icons.payment, size: 18),
                        //     label: const Text("Pay", style: TextStyle(fontWeight: FontWeight.bold)),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.amber,
                        //       foregroundColor: Colors.black87,
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        //       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        //     ),
                        //   )
                        // else
                        //   Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        //     decoration: BoxDecoration(
                        //       color: Colors.green.withOpacity(0.15),
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: const Text(
                        //       "Paid",
                        //       style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        //     ),
                        //   ),
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