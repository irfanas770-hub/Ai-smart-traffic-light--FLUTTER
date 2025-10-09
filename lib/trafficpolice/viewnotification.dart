import 'package:aismarttrafficlight/trafficpolice/addnotification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

// import 'editprofile.dart';
void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Notification',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const viewnotification(title: 'View Notification'),
    );
  }
}

class viewnotification extends StatefulWidget {
  const viewnotification({super.key, required this.title});

  final String title;

  @override
  State<viewnotification> createState() => _viewnotificationState();
}

class _viewnotificationState extends State<viewnotification> {

  _viewnotificationState()
  {
    _send_data();
  }
  @override
  Widget build(BuildContext context) {



    return WillPopScope(
      onWillPop: () async{ return true; },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton( ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[


              // CircleAvatar(radius: 50,),
              Column(
                children: [
              //     Image(image: NetworkImage(photo_),height: 200,width: 200,),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(date),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(notification),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(gender_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(email_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(phone_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(place_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(post_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(pin_),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(5),
                  //   child: Text(district_),
                  // ),

                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => addnotification(title: " Delete"),));
                },
                child: Text("Delete"),
              ),

            ],
          ),
        ),
      ),
    );
  }


  String date="Date";
  String notification="Notification";

  void _send_data() async{



    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/myapp/user_myApp/');
    try {
      final response = await http.post(urls, body: {
        'lid':lid



      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          String date=jsonDecode(response.body)['date'];
          String notification=jsonDecode(response.body)['notification'];
          // String gender=jsonDecode(response.body)['gender'];
          // String email=jsonDecode(response.body)['email'];
          // String phone=jsonDecode(response.body)['phone'];
          // String place=jsonDecode(response.body)['place'];
          // String post=jsonDecode(response.body)['post'];
          // String pin=jsonDecode(response.body)['pin'];
          // String district=jsonDecode(response.body)['district'];
          // String photo=url+jsonDecode(response.body)['photo'];

          setState(() {

            date= date;
            notification= notification;
            // gender_= gender;
            // email_= email;
            // phone_= phone;
            // place_= place;
            // post_= post;
            // pin_= pin;
            // district_= district;
            // photo_= photo;
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
