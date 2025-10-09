


import 'dart:io';

import 'package:aismarttrafficlight/emergencyvehicle/viewprofile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart ';

import 'package:permission_handler/permission_handler.dart';

import '../trafficpolice/viewprofile.dart';


void main() {
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ev_edit_profile(title: 'Edit Profile'),
    );
  }
}

class ev_edit_profile extends StatefulWidget {
  const ev_edit_profile({super.key, required this.title});

  final String title;

  @override
  State<ev_edit_profile> createState() => _ev_edit_profileState();
}

class _ev_edit_profileState extends State<ev_edit_profile> {

  _ev_edit_profileState()
  {
    _get_data();
  }

  // String gender = "Male"; TextEditingController nameController= new TextEditingController();
  TextEditingController typeController= new TextEditingController();
  TextEditingController vehiclenumberController= new TextEditingController();
  TextEditingController drivernameController= new TextEditingController();
  TextEditingController phoneController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();
  // TextEditingController pinController= new TextEditingController();
  // TextEditingController districtController= new TextEditingController();
  String upic="";


  void _get_data() async{



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
          String photo=img+jsonDecode(response.body)['photo'].toString();

          typeController.text=type;
          vehiclenumberController.text=vehiclenumber;
          drivernameController.text=drivername;
          phoneController.text=phone;
          emailController.text=email;
          setState(() {


            upic=photo;

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

              if (_selectedImage != null) ...{
                InkWell(
                  child:
                  Image.file(_selectedImage!, height: 400,),
                  radius: 399,
                  onTap: _checkPermissionAndChooseImage,
                  // borderRadius: BorderRadius.all(Radius.circular(200)),
                ),
              } else ...{
                // Image(image: NetworkImage(),height: 100, width: 70,fit: BoxFit.cover,),
                InkWell(
                  onTap: _checkPermissionAndChooseImage,
                  child:Column(
                    children: [
                      Image(image: NetworkImage(upic),height: 200,width: 200,),
                      Text('Select Image',style: TextStyle(color: Colors.cyan))
                    ],
                  ),
                ),
              },

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
              // RadioListTile(value: "Male", groupValue: gender, onChanged: (value) { setState(() {gender="Male";}); },title: Text("Male"),),
              // RadioListTile(value: "Female", groupValue: gender, onChanged: (value) { setState(() {gender="Female";}); },title: Text("Female"),),
              // RadioListTile(value: "Other", groupValue: gender, onChanged: (value) { setState(() {gender="Other";}); },title: Text("Other"),),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: drivernameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Driver Name")),
                ),
              ),   Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Phone")),
                ),
              ),   Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Email")),
                ),
              ),


              ElevatedButton(
                onPressed: () {
                  _send_data();

                },
                child: Text("Edit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _send_data() async{

    String evtype=typeController.text;
    String vehiclenumber=vehiclenumberController.text;
    String drivername=drivernameController.text;
    String phone=phoneController.text;
    String email=emailController.text;


    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/ev_editprofile_post/');
    try {

      final response = await http.post(urls, body: {
        "photo":photo_,
        'type':evtype,
        'vehiclenumber':vehiclenumber,
        'drivername':drivername,
        'phone':phone,
        'email':email,
        'lid':lid,

      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {

          Fluttertoast.showToast(msg: 'Updated Successfully');
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ev_view_profile(title: "Profile"),));
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
  File? _selectedImage;
  String? _encodedImage;
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        photo_ = _encodedImage.toString();
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String photo_ = '';

}
