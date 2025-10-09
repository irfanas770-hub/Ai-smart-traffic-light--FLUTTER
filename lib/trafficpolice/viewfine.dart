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
      home: viewfine(title: 'View Users'),
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
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewfine("");
  }

  Future<void> viewfine(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid') ?? '';
      String apiUrl = '$urls/tp_viewfine_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'photo': img + item['photo'],
            'id': item['id'],
            'fine': item['fine'],
            'date': item['date'],
            'time': item['time'],
            'status': item['status'],
            'vehiclenumber': item['vehiclenumber'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['status']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['status'].toString()).toSet().toList();
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
                    backgroundImage: NetworkImage(user['photo']),
                    radius: 30,
                  ),
                  // title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fine: ${user['fine']}"),
                      Text("Date: ${user['date']}"),
                      Text("Time: ${user['time']}"),
                      Text("Status: ${user['status']}"),
                      Text("Vehicle No: ${user['vehiclenumber']}"),
                      // ElevatedButton(
                      //     onPressed: () async{
                      //       SharedPreferences sh = await SharedPreferences.getInstance();
                      //       sh.setString("vid", user["id"].toString());
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => addfine(title: '',),
                      //           ));
                      //     },
                      //     child: Text("addfine")),

                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
