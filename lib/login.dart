

import 'dart:convert';
import 'package:aismarttrafficlight/trafficpolice/tphome.dart';
import 'package:aismarttrafficlight/user/home.dart';
import 'package:aismarttrafficlight/user/signup.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// import 'home.dart';
import 'emergencyvehicle/evhome.dart';
import 'emergencyvehicle/signup.dart';
import 'main.dart';
// import 'newhome.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyLoginPage(title: 'Login'),
  ));
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final TextEditingController _usernametextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: '',)),
      );
      return false; // Prevent default pop
    },
    child:Scaffold(
      backgroundColor: const Color(0xFFEFF3FF), // Light blue background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Shape and Logo
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0047AB),
                    borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(80)),
                  ),
                ),
                const Positioned(
                  top: 100,
                  left: 20,
                  child: Text(
                    ' Login',
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email id",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernametextController,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Password",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  TextField(
controller: _passwordtextController,
                    // obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _send_data,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Login",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Forgot Password ?",
                          style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Divider
                  Row(children: const <Widget>[
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 20),

                  // Facebook Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {},
                  //     icon: const Icon(Icons.facebook, color: Colors.white),
                  //     label: const Text("Log in with Facebook"),
                  //     style: ElevatedButton.styleFrom(
                  //         backgroundColor: const Color(0xFF1877F2),
                  //         padding: const EdgeInsets.symmetric(vertical: 14),
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(8))),
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  // Register Prompt
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style: TextStyle(color: Colors.black87)),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MyMySignupPage(title: '',)));
                      }, child: const Text('User signup')),
                      const Text("Don't have an account vehicle? ",
                          style: TextStyle(color: Colors.black87)),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ev_signup(title: '',)));
                      }, child: const Text('Emergency signup'))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  void _send_data() async {
    String uname = _usernametextController.text;
    String password = _passwordtextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/user_login_post/');
    try {
      final response = await http.post(urls, body: {
        'uname': uname,
        'password': password,
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String lid = jsonDecode(response.body)['lid'].toString();
          String type = jsonDecode(response.body)['type'].toString();
          sh.setString("lid", lid);

          if (type == "Customer"){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => userhome()),
            );
          }
          else if(type == 'Emergency vehicle'){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => evhome()),
            );
          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => tphome()),
            );
          }


        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
