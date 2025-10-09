

import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart ';

import 'package:permission_handler/permission_handler.dart';
import '../login.dart';


void main() {
  runApp(const MyMySignup());
}

class MyMySignup extends StatelessWidget {
  const MyMySignup({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySignup',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyMySignupPage(title: 'MySignup'),
    );
  }
}

class MyMySignupPage extends StatefulWidget {
  const MyMySignupPage({super.key, required this.title});

  final String title;

  @override
  State<MyMySignupPage> createState() => _MyMySignupPageState();
}

class _MyMySignupPageState extends State<MyMySignupPage> {

  String gender = "Male";
  File? uploadimage;
  TextEditingController nameController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController dobController= new TextEditingController();
  TextEditingController genderController= new TextEditingController();
  TextEditingController placeController= new TextEditingController();
  TextEditingController pinController= new TextEditingController();
  TextEditingController postController= new TextEditingController();
  TextEditingController districtController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();
  TextEditingController confirmpasswordController= new TextEditingController();





  File? _selectedImage;
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
                  controller: nameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Name")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Email")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Phone")),
                ),
              ),  Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  onTap: ()async{
                    DateTime? dt=await showDatePicker(context: context, firstDate: DateTime(1990), lastDate: DateTime.now());
                    String fd='${dt!.year}-${dt.month}-${dt.day}';
                    setState(() {
                      dobController.text=fd;
                    });
                  },
                  controller: dobController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("DOB")),
                ),
              ),

              RadioListTile(value: "Male", groupValue: gender, onChanged: (value) { setState(() {gender="Male";}); },title: Text("Male"),),
              RadioListTile(value: "Female", groupValue: gender, onChanged: (value) { setState(() {gender="Female";}); },title: Text("Female"),),
              RadioListTile(value: "Other", groupValue: gender, onChanged: (value) { setState(() {gender="Other";}); },title: Text("Other"),),

              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller:placeController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Place")),
                ),
              ),   Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: pinController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Pin")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller:postController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Post")),
                ),
              ),       Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: districtController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("District")),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller:passwordController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Password")),
                ),
              ),     Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller:confirmpasswordController,

                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Confirm Password")),
                ),
              ),

              ElevatedButton(
                onPressed: () {

                  _send_data() ;

                },
                child: Text("Signup"),
              ),TextButton(
                onPressed: () {},
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _send_data() async{

    String uname=nameController.text;
    String uemail=emailController.text;
    String uphone=phoneController.text;
    String udob=dobController.text;
    String ugender=genderController.text;
    String uplace=placeController.text;
    String upin=pinController.text;
    String upost=postController.text;
    String udistrict=districtController.text;
    String upassword=passwordController.text;
    String uconfirmpassword=confirmpasswordController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/user_signup_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['uname'] = uname;
    request.fields['uemail'] = uemail;
    request.fields['uphone'] = uphone;
    request.fields['udob'] = udob;
    request.fields['ugender'] = gender;
    request.fields['uplace'] = uplace;
    request.fields['upin'] = upin;
    request.fields['upost'] = upost;
    request.fields['udistrict'] = udistrict;
    request.fields['upassword'] = upassword;
    request.fields['uconfirmpassword'] = uconfirmpassword;

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

}
