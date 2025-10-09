import 'dart:convert';

import 'package:aismarttrafficlight/emergencyvehicle/edit_emergency_trip.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


// import 'home.dart';
// import 'newhome.dart';

void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: view_emergency_trip(title: 'View Users'),
    );
  }
}

class view_emergency_trip extends StatefulWidget {
  const view_emergency_trip({super.key, required this.title});
  final String title;

  @override
  State<view_emergency_trip> createState() => _view_emergency_tripState();
}

class _view_emergency_tripState extends State<view_emergency_trip> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    view_emergency_trip("");
  }

  Future<void> view_emergency_trip(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid') ?? '';
      String apiUrl = '$urls/view_emergency_trip/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'date': item['date'],
            'time': item['time'],
            'destination': item['destination'],
            'status':item['status'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['Type']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['Type'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => const BankingDashboard()),
          // );
          return true; // Prevent default pop
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 232, 177, 61),
            title: Text('View Emergency Trip'),
          ),
          body: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: ListTile(
                  // title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${user['date']}"),
                      Text("Time: ${user['time']}"),
                      Text("Destination: ${user['destination']}"),
                      Text("Status: ${user['status']}"),
                      ElevatedButton(
                          onPressed: () async{
                            SharedPreferences sh=await SharedPreferences.getInstance();
                            sh.setString('tid', user['id'].toString());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => edit_emergency_trip(title: '',),));
                          },
                          child: Text("Edit")),
                      ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();
                            String? url = sh.getString('url');
                            // String lid = sh.getString('lid').toString();

                            if (url == null) {
                              Fluttertoast.showToast(
                                  msg: "Server URL not found.");
                              return;
                            }

                            final uri =
                            Uri.parse('$url/delete_emergency_trip/');
                            var request = http.MultipartRequest('POST', uri);
                            request.fields['id'] = user['id'].toString();

                            try {
                              var response = await request.send();
                              var respStr =
                              await response.stream.bytesToString();
                              var data = jsonDecode(respStr);

                              if (response.statusCode == 200 &&
                                  data['status'] == 'ok') {
                                view_emergency_trip('');
                                Fluttertoast.showToast(
                                    msg: "deleted successfully.");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Submission failed.");
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: "Error: $e");
                            }
                          },
                          child: Text("Delete")),
                      user["status"]=="pending"?ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                            await SharedPreferences.getInstance();
                            String? url = sh.getString('url');
                            // String lid = sh.getString('lid').toString();

                            if (url == null) {
                              Fluttertoast.showToast(
                                  msg: "Server URL not found.");
                              return;
                            }

                            final uri =
                            Uri.parse('$url/update_emergency_trip_status/');
                            var request = http.MultipartRequest('POST', uri);
                            request.fields['id'] = user['id'].toString();

                            try {
                              var response = await request.send();
                              var respStr =
                              await response.stream.bytesToString();
                              var data = jsonDecode(respStr);

                              if (response.statusCode == 200 &&
                                  data['status'] == 'ok') {
                                view_emergency_trip('');
                                Fluttertoast.showToast(
                                    msg: "updated successfully.");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Submission failed.");
                              }
                            } catch (e) {
                              Fluttertoast.showToast(msg: "Error: $e");
                            }
                          },
                          child: Text("update")):Text(''),

                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
