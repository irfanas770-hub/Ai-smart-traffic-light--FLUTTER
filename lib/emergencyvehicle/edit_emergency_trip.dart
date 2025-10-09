// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// // import 'home.dart';
// // import 'newhome.dart';
//
//
// void main() {
//   runApp( edit_emergency_trip(title: '',));
// }
//
// class edit_emergency_trip extends StatefulWidget {
//   const edit_emergency_trip({super.key, required this.title});
//
//   final String title;
//   @override
//   State<edit_emergency_trip> createState() => _edit_emergency_tripState();
//
// }
// class _edit_emergency_tripState extends State<edit_emergency_trip> {
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _datetextController = TextEditingController();
//   final TextEditingController _timetextController = TextEditingController();
//   final TextEditingController _destinationtextController = TextEditingController();
//
//   Future<void> _sendData() async {
//     String evdate = _datetextController.text;
//     String evtime = _timetextController.text;
//     String evdestination = _destinationtextController.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String lid = sh.getString('lid').toString();
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "Server URL not found.");
//       return;
//     }
//
//     final uri = Uri.parse('$url/ev_add_emergency_trip_post/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['date'] = evdate;
//     request.fields['time'] = evtime;
//     request.fields['destination'] = evdestination;
//     request.fields['lid'] = lid;
//
//     // if (_selectedImage != null) {
//     //   request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
//     // }
//
//     try {
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Submitted successfully.");
//       } else {
//         Fluttertoast.showToast(msg: "Submission failed.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => const BankingDashboard()),
//         // );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//           centerTitle: true,
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Colors.white,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _datetextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Date',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Date is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _timetextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Time',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Time is required';
//                     }
//                     // if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                     //   return 'Enter a valid email ';
//                     // }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _destinationtextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your Destination',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.String,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Destination is required';
//                     }
//                     // if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                     //   return 'Enter a valid 10-digit phone number';
//                     // }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _sendData();
//                     } else {
//                       Fluttertoast.showToast(msg: "Please fix errors in the form");
//                     }
//                   },
//                   child: const Text("Submit"),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:aismarttrafficlight/emergencyvehicle/view_emergency_trip.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: edit_emergency_trip(title: 'Add Emergency Trip')));
}

class edit_emergency_trip extends StatefulWidget {
  const edit_emergency_trip({super.key, required this.title});
  final String title;

  @override
  State<edit_emergency_trip> createState() => _edit_emergency_tripState();
}

class _edit_emergency_tripState extends State<edit_emergency_trip> {

  _edit_emergency_tripState(){
    _send_data();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _datetextController = TextEditingController();
  final TextEditingController _timetextController = TextEditingController();
  final TextEditingController _destinationtextController = TextEditingController();

  Future<void> _sendData() async {
    String evdate = _datetextController.text;
    String evtime = _timetextController.text;
    String evdestination = _destinationtextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String tid = sh.getString('tid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/edit_emergency_trip_post/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['date'] = evdate;
    request.fields['time'] = evtime;
    request.fields['destination'] = evdestination;
    request.fields['tid'] = tid;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>view_emergency_trip(title: '',)));
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  String date_="";
  String time_="";
  String destination_="";


  void _send_data() async{

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String tid = sh.getString('tid').toString();
    String img = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/edit_emergency_trip_get/');
    try {
      final response = await http.post(urls, body: {
        'tid':tid

      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status=='ok') {
          String date=jsonDecode(response.body)['date'];
          String time=jsonDecode(response.body)['time'];
          String destination=jsonDecode(response.body)['destination'];


          setState(() {

            _datetextController.text= date;
            _timetextController.text= time;
            _destinationtextController.text= destination;

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

  /// 📅 Show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _datetextController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  /// ⏰ Show Time Picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timetextController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 20),

              // 📅 Date Picker Field
              TextFormField(
                controller: _datetextController,
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // ⏰ Time Picker Field
              TextFormField(
                controller: _timetextController,
                decoration: const InputDecoration(
                  labelText: 'Select Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Time is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // 🗺 Destination Field
              TextFormField(
                controller: _destinationtextController,
                decoration: const InputDecoration(
                  labelText: 'Enter Destination',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Destination is required';
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
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
