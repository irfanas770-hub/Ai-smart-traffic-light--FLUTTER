import 'dart:convert';
import 'package:aismarttrafficlight/emergencyvehicle/view_emergency_trip.dart';
import 'package:aismarttrafficlight/emergencyvehicle/viewprofile.dart';
import 'package:aismarttrafficlight/login.dart';
import 'package:http/http.dart' as http;
import 'package:aismarttrafficlight/user/addownvehicle.dart';
import 'package:aismarttrafficlight/user/viewevalert.dart';
import 'package:aismarttrafficlight/user/viewfineentryandpay.dart';
import 'package:aismarttrafficlight/user/viewnearbynotification.dart';
import 'package:aismarttrafficlight/user/viewnearbytsalert.dart';
import 'package:aismarttrafficlight/user/viewownvehicle.dart';
import 'package:aismarttrafficlight/user/viewpaidlogs.dart';
import 'package:aismarttrafficlight/user/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_emergencytrip.dart';
// import 'package:smart_billing/view_user.dart';
//
// import 'add_user.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'evhome Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const evhome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class evhome extends StatefulWidget {
  const evhome({super.key});

  @override
  State<evhome> createState() => _evhomeState();
}

class _evhomeState extends State<evhome> {
  _evhomeState(){
    _send_data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome evhome'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  photo_,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Hello, ${type_}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Glad to see you back.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => add_emergencytrip(title: '')),
                );
              },
              child: const Text('Add Emergency Trip'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => viewevalert(title: '')),
            //     );
            //   },
            //   child: const Text('View Finish Trip'),
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size.fromHeight(50),
            //   ),
            // ),
            const SizedBox(height: 20),



            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ev_view_profile(title: '')),
                );
              },
              child: const Text('View Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 20),



            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => view_emergency_trip(title: '')),
                );
              },
              child: const Text('View Emergency Trip'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),






            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>MyLoginPage(title: '',),));
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String type_="";
  String vehiclenumber_="";
  String drivername_="";
  String phone_="";
  String email_="";
  String photo_="";

  void _send_data() async{



    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String img_url = sh.getString('img_url').toString();
    String lid = sh.getString('lid').toString();
    print(url);

    final urls = Uri.parse('$url/ev_viewprofile_post/');
    try {
      final response = await http.post(urls, body: {
        'lid':lid



      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          String type=jsonDecode(response.body)['type'];
          String vehiclenumber=jsonDecode(response.body)['vehiclenumber'];
          String drivername=jsonDecode(response.body)['drivername'];
          String phone=jsonDecode(response.body)['phone'];
          String email=jsonDecode(response.body)['email'];
          String photo=img_url+jsonDecode(response.body)['photo'];

          setState(() {

            type_= type;
            vehiclenumber_= vehiclenumber;
            drivername_= drivername;
            phone_= phone;
            email_= email;
            photo_= photo;
          });





        }else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      }
      else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    }
    catch (e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}

