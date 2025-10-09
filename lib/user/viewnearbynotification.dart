import 'dart:convert';

import 'package:flutter/material.dart';
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
      home: viewnearbynotification(title: 'View Users'),
    );
  }
}

class viewnearbynotification extends StatefulWidget {
  const viewnearbynotification({super.key, required this.title});
  final String title;

  @override
  State<viewnearbynotification> createState() => _viewnearbynotificationState();
}

class _viewnearbynotificationState extends State<viewnearbynotification> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewnearbynotification("");
  }

  Future<void> viewnearbynotification(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/user_viewnearby_notification_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'date': item['date'],
            'message':item['message'],
          });
        }
        setState(() {
          users = tempList;

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
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 232, 177, 61),
            title: Text('View Nearby Notification'),
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
                  // leading: CircleAvatar(
                  //   backgroundImage: NetworkImage(user['photo']),
                  //   radius: 30,
                  // ),
                  // // title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Date: ${user['date']}"),
                      Text("Message: ${user['message']}"),

                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
