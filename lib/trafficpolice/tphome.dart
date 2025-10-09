import 'dart:convert';
import 'package:aismarttrafficlight/login.dart';
import 'package:aismarttrafficlight/trafficpolice/viewfine.dart';
import 'package:aismarttrafficlight/trafficpolice/viewprofile.dart';
import 'package:aismarttrafficlight/trafficpolice/viewvehicle.dart';
import 'package:aismarttrafficlight/user/view_evtrip.dart';
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

import 'addfine.dart';
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
      title: 'tphome Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const tphome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class tphome extends StatefulWidget {
  const tphome({super.key});

  @override
  State<tphome> createState() => _tphomeState();
}

class _tphomeState extends State<tphome> {
  _tphomeState(){
    _send_data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome tphome'),
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
                'Hello, ${station_}!',
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
                  MaterialPageRoute(builder: (context) => viewvehicle(title: '')),
                );
              },
              child: const Text('Add Fine'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewevalert(title: '')),
                );
              },
              child: const Text('Add Notification'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ), const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewfine(title: '')),
                );
              },
              child: const Text('View Fine'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),



            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewnearbynotification(title: '')),
                );
              },
              child: const Text('View Notification'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => tpviewprofile(title: '')),
                );
              },
              child: const Text('View Profile'),
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
  String photo_="";
  String number_="";
  String email_="";
  String station_="";
  String proof_="";

  void _send_data() async{



    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String img = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/tp_viewprofile_post/');
    try {
      final response = await http.post(urls, body: {
        'lid':lid



      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          String number=jsonDecode(response.body)['number'];
          String email=jsonDecode(response.body)['email'];
          String station=jsonDecode(response.body)['station'];
          String proof=img+jsonDecode(response.body)['proof'];
          String photo=img+jsonDecode(response.body)['photo'];

          setState(() {

            number_= number;
            email_= email;
            station_= station;
            proof_= proof;
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

