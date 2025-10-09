import 'dart:convert';

import 'package:aismarttrafficlight/user/editownvehicle.dart';
import 'package:aismarttrafficlight/user/viewfineentryandpay.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'addfine.dart';

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
      home: viewvehicle(title: 'View Users'),
    );
  }
}

class viewvehicle extends StatefulWidget {
  const viewvehicle({super.key, required this.title});
  final String title;

  @override
  State<viewvehicle> createState() => _viewvehicleState();
}

class _viewvehicleState extends State<viewvehicle> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewvehicle("");
  }

  Future<void> viewvehicle(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid') ?? '';
      String apiUrl = '$urls/tp_viewvehicle_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
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
            title: Text('View Vehicle'),
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
                          onPressed: () async{
                            SharedPreferences sh = await SharedPreferences.getInstance();
                            sh.setString("vid", user["id"].toString());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => addfine(title: '',),
                                ));
                          },
                          child: Text("addfine")),

                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
