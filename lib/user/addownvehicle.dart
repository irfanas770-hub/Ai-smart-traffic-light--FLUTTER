import 'dart:convert';
import 'dart:io';
import 'package:aismarttrafficlight/user/editownvehicle.dart';
import 'package:aismarttrafficlight/user/viewownvehicle.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'home.dart';
// import 'newhome.dart';


void main() {
  runApp( addownvehicle(title: '',));
}

class addownvehicle extends StatefulWidget {
  const addownvehicle({super.key, required this.title});

  final String title;
  @override
  State<addownvehicle> createState() => _addownvehicleState();

}
class _addownvehicleState extends State<addownvehicle> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typetextController = TextEditingController();
  final TextEditingController _fueltypetextController = TextEditingController();
  final TextEditingController _vehiclenotextController = TextEditingController();

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

  Future<void> _sendData() async {
    String utype = _typetextController.text;
    String ufueltype = _fueltypetextController.text;
    String uvehicleno = _vehiclenotextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/user_addownvehicle_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['utype'] = utype;
    request.fields['ufueltype'] = ufueltype;
    request.fields['uvehicleno'] = uvehicleno;
    request.fields['lid'] = lid.toString();

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const BankingDashboard()),
        // );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150)
                    : const Text("No Image Selected"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _chooseImage,
                  child: const Text("Choose Image"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _typetextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Type',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Type is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fueltypetextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Fuel Type',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fuel Type is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _vehiclenotextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Vehicle Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vehicle number is required';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendData();
                    } else {
                      Fluttertoast.showToast(msg: "Please fix errors in the form");
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
