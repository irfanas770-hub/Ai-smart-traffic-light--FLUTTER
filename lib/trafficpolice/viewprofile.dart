import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'editprofile.dart';
void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const tpviewprofile(title: 'View Profile'),
    );
  }
}

class tpviewprofile extends StatefulWidget {
  const tpviewprofile({super.key, required this.title});

  final String title;

  @override
  State<tpviewprofile> createState() => _tpviewprofileState();
}

class _tpviewprofileState extends State<tpviewprofile> {

  _tpviewprofileState()
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
            //
            //
              CircleAvatar(radius: 50,
              backgroundImage: NetworkImage(photo_),),
              Column(
                children: [
                  // Image(image: NetworkImage(photo_),height: 200,width: 200,),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(number_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(email_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(station_),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  ElevatedButton(onPressed: () async {

                    if (!await launchUrl(Uri.parse(proof_))) {
                    throw Exception('Could not launch ');
                    }

                  }, child: Text('view'))

                ],
              ),

            ],
          ),
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
