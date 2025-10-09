import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'editprofile.dart';
void main() {
  runApp(const ViewProfile());
}

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ev_view_profile(title: 'View Profile'),
    );
  }
}

class ev_view_profile extends StatefulWidget {
  const ev_view_profile({super.key, required this.title});

  final String title;

  @override
  State<ev_view_profile> createState() => _ev_view_profileState();
}

class _ev_view_profileState extends State<ev_view_profile> {

  _ev_view_profileState()
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


              CircleAvatar(radius: 50,
              backgroundImage: NetworkImage(photo_),),
              Column(
                children: [
                  // Image(image: NetworkImage(photo_),height: 200,width: 200,),
                  Padding(
                    padding: EdgeInsets.all(5),
                  child: Text(type_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(vehiclenumber_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(drivername_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(phone_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(email_),
                  ),


                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ev_edit_profile(title: "Edit Profile"),));
                },
                child: Text("Edit Profile"),
              ),

            ],
          ),
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
    String lid = sh.getString('lid').toString();
    String img = sh.getString('img_url').toString();

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
          String photo=img+jsonDecode(response.body)['photo'];

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
