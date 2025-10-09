

import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart ';

import 'package:permission_handler/permission_handler.dart';

import '../login.dart';
// import 'login.dart';


void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myev_signup',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ev_signup(title: 'Myev_signup'),
    );
  }
}

class ev_signup extends StatefulWidget {
  const ev_signup({super.key, required this.title});

  final String title;

  @override
  State<ev_signup> createState() => _ev_signupState();
}

class _ev_signupState extends State<ev_signup> {

  String gender = "Male";
  File? _selectedImage;
  TextEditingController typeController= new TextEditingController();
  TextEditingController vehiclenumberController= new TextEditingController();
  TextEditingController drivernameController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();


  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
    else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }



  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{ return true; },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : const Text("No Image Selected"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _chooseImage,
                child: const Text("Choose Image"),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: typeController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Type")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: vehiclenumberController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Vehicle Number")),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: drivernameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Driver Name")),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: phoneController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("phone")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: emailController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Email")),
                ),
              ),


              ElevatedButton(
                onPressed: () {

                 _send_data() ;

                },
                child: Text("ev_signup"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _send_data() async{


    String evtype=typeController.text;
    String evvehiclenumber=vehiclenumberController.text;
    String evdrivername=drivernameController.text;
    String evphone=phoneController.text;
    String evemail=emailController.text;


    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/ev_signup_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['evtype'] = evtype;
    request.fields['evvehiclenumber'] = evvehiclenumber;
    request.fields['evdrivername'] = evdrivername;
    request.fields['evphone'] = evphone;
    request.fields['evemail'] = evemail;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Navigator.push(context, MaterialPageRoute(
          // builder: (context) => MyLoginPage(title: "Login"),));
          builder: (context) =>MyLoginPage(title: '',),));
        Fluttertoast.showToast(msg: "Submitted successfully.");
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
  String photo = '';

}
