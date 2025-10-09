import 'dart:convert';

import 'package:aismarttrafficlight/user/editownvehicle.dart';
import 'package:aismarttrafficlight/user/viewfineentryandpay.dart';
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
      home: viewownvehicle(title: 'View Users'),
    );
  }
}

class viewownvehicle extends StatefulWidget {
  const viewownvehicle({super.key, required this.title});
  final String title;

  @override
  State<viewownvehicle> createState() => _viewownvehicleState();
}

class _viewownvehicleState extends State<viewownvehicle> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewownvehicle("");
  }

  Future<void> viewownvehicle(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid') ?? '';
      String apiUrl = '$urls/user_viewownvehicle_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'Photo': img + item['photo'],
            'id': item['id'],
            'Type': item['type'],
            'Fuel Type': item['fueltype'],
            'Vehicle No': item['vehiclenumber'],
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
            title: Text('View Own Vehicle'),
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
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['Photo']),
                    radius: 30,
                  ),
                  // title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: ${user['Type']}"),
                      Text("Fuel Type: ${user['Fuel Type']}"),
                      Text("Vehicle No: ${user['Vehicle No']}"),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => editownvehicle(
                                    title: "Edit ",
                                    utype: user['Type'],
                                    fueltype: user['Fuel Type'],
                                    vehicleno: user['Vehicle No'],
                                    lid: user['id'].toString(),
                                    photo: user['Photo'],
                                  ),
                                ));
                          },
                          child: Text("Edit")),
                      ElevatedButton(
                          onPressed: () async {
                            SharedPreferences sh =
                                await SharedPreferences.getInstance();
                            String? url = sh.getString('url');
                            String? lid = sh.getString('lid');

                            if (url == null) {
                              Fluttertoast.showToast(
                                  msg: "Server URL not found.");
                              return;
                            }

                            final uri =
                                Uri.parse('$url/delete_ownvehicle/');
                            var request = http.MultipartRequest('POST', uri);
                            request.fields['id'] = user['id'].toString();

                            try {
                              var response = await request.send();
                              var respStr =
                                  await response.stream.bytesToString();
                              var data = jsonDecode(respStr);

                              if (response.statusCode == 200 &&
                                  data['status'] == 'ok') {
                                viewownvehicle('');
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
                      ElevatedButton(
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => viewfineentry(title: '', id: user['id'].toString(),)),
                          );
                        },
                        child: const Text('View Fine Entry And Pay'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
