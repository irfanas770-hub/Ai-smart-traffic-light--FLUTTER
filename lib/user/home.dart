import 'dart:convert';
import 'package:aismarttrafficlight/login.dart';
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
      title: 'userhome Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const userhome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class userhome extends StatefulWidget {
  const userhome({super.key});

  @override
  State<userhome> createState() => _userhomeState();
}

class _userhomeState extends State<userhome> {
  _userhomeState(){
    _send_data();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome userhome'),
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
                'Hello, ${name_}!',
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
                  MaterialPageRoute(builder: (context) => addownvehicle(title: '')),
                );
              },
              child: const Text('Add own vehicle'),
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
              child: const Text('View EV alert'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ), const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => view_evtrip(title: '')),
                );
              },
              child: const Text('View EV trip'),
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
              child: const Text('View Nearby Notification'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewnearbytsalert(title: '')),
                );
              },
              child: const Text('View Nearby TS Alert'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewownvehicle(title: '')),
                );
              },
              child: const Text('View own vehicle'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => viewpaidlogs(title: '')),
                );
              },
              child: const Text('View Paid Logs'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProfilePage(title: '')),
                );
              },
              child: const Text('View Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 20),






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
  String name_="";
  String email_="";
  String phone_="";
  String dob_="";
  String gender_="";
  String place_="";
  String pin_="";
  String post_="";
  String district_="";
  String photo_="";

  void _send_data() async{



    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String img_url = sh.getString('img_url').toString();
    String lid = sh.getString('lid').toString();
    print(url);

    final urls = Uri.parse('$url/user_viewprofile_post/');
    try {
      final response = await http.post(urls, body: {
        'lid':lid



      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          String name=jsonDecode(response.body)['name'];
          String email=jsonDecode(response.body)['email'];
          String phone=jsonDecode(response.body)['phone'];
          String dob=jsonDecode(response.body)['dob'];
          String gender=jsonDecode(response.body)['gender'];
          String place=jsonDecode(response.body)['place'];
          String pin=jsonDecode(response.body)['pin'];
          String post=jsonDecode(response.body)['post'];
          String district=jsonDecode(response.body)['district'];
          String photo=img_url+jsonDecode(response.body)['photo'];

          setState(() {

            name_= name;
            email_= email;
            phone_= phone;
            dob_= dob;
            gender_= gender;
            place_= place;
            pin_= pin;
            post_= post;
            district_= district;
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

