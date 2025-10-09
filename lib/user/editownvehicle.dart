// import 'package:clinicpharma/viewprofile.dart';


import 'dart:io';

import 'package:aismarttrafficlight/user/viewownvehicle.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart ';

import 'package:permission_handler/permission_handler.dart';




class editownvehicle extends StatefulWidget {
  const editownvehicle({super.key, required this.title, required this.utype, required this.fueltype, required this.vehicleno, required this.lid, required this.photo});

  final String title;
  final String utype;
  final String fueltype;
  final String vehicleno;
  final String photo;
  final String lid;

  @override
  State<editownvehicle> createState() => _editownvehicleState();
}

class _editownvehicleState extends State<editownvehicle> {

 @override
  void initState() {
    // TODO: implement initState
   _get_data();
    super.initState();
  }
  TextEditingController typeController= new TextEditingController();
  TextEditingController fueltypeController= new TextEditingController();
  TextEditingController vehiclenoController= new TextEditingController();

String up="";

  void _get_data() async{
    setState(() {
      typeController.text=widget.utype;
      fueltypeController.text=widget.fueltype;
      vehiclenoController.text=widget.vehicleno;
      up=widget.photo;
    });
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
                  : Image.network(up, height: 150),
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
                  controller: fueltypeController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Fuel type")),
                ),
              ),
               Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: vehiclenoController,
                  decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Vehicle Number")),
                ),
              ),



              ElevatedButton(
                onPressed: () {
                  _sendData();

                },
                child: Text("Confirm Edit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
 Future<void> _sendData() async {
   String utype = typeController.text;
   String ufueltype = fueltypeController.text;
   String uvehicleno = vehiclenoController.text;

   SharedPreferences sh = await SharedPreferences.getInstance();
   String? url = sh.getString('url');
   String? lid = sh.getString('lid');

   if (url == null) {
     Fluttertoast.showToast(msg: "Server URL not found.");
     return;
   }

   final uri = Uri.parse('$url/user_editownvehicle_post/');
   var request = http.MultipartRequest('POST', uri);
   request.fields['utype'] = utype;
   request.fields['ufueltype'] = ufueltype;
   request.fields['uvehicleno'] = uvehicleno;
   request.fields['id'] = widget.lid;

   if (_selectedImage != null) {
     request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
   }

   try {
     var response = await request.send();
     var respStr = await response.stream.bytesToString();
     var data = jsonDecode(respStr);

     if (response.statusCode == 200 && data['status'] == 'ok') {
       Navigator.push(context,MaterialPageRoute(builder:(context) => viewownvehicle(title: '',),));
       Fluttertoast.showToast(msg: "Submitted successfully.");
     } else {
       Fluttertoast.showToast(msg: "Submission failed.");
     }
   } catch (e) {
     Fluttertoast.showToast(msg: "Error: $e");
   }
 }


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

}
