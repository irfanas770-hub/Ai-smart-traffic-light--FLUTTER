import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class viewfineentry extends StatefulWidget {
  const viewfineentry({super.key, required this.title, required this.id});
  final String title;
  final String id;

  @override
  State<viewfineentry> createState() => _viewfineentryState();
}

class _viewfineentryState extends State<viewfineentry> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  @override
  void initState() {
    super.initState();
    viewfineentry();
  }

  Future<void> viewfineentry() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/user_viewfineentryandpay_post/';

      var response = await http.post(Uri.parse(apiUrl), body: {
        'vid':widget.id
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'photo':img+ item['photo'],
            'id':item['id'],
            'date': item['date'],
            'fine': item['fine'],
            'time': item['time'],
            'status':item['status'],
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
            title: Text('View Fine Entry & Pay'),
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

                      Text("Date: ${user['date']}"),
                      Text("Fine: ${user['fine']}"),
                      Text("Time: ${user['time']}"),
                      Text("Status: ${user['status']}"),
                      ElevatedButton(onPressed: (){
                        print("Payment");
                      }, child: Text("Payment")),
                    ],
                  ),
                ),
              );
            },
          ),
        ));
  }
}
