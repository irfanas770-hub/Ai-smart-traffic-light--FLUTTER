

            import 'dart:io';

            import 'package:aismarttrafficlight/user/viewprofile.dart';
            import 'package:http/http.dart' as http;
            import 'dart:convert';

            import 'package:flutter/material.dart';
            import 'package:fluttertoast/fluttertoast.dart';
            import 'package:shared_preferences/shared_preferences.dart';
            import 'package:image_picker/image_picker.dart ';

            import 'package:permission_handler/permission_handler.dart';
            import '../login.dart';


            void main() {
              runApp(const myApp());
            }

            class myApp extends StatelessWidget {
              const myApp({super.key});

              @override
              Widget build(BuildContext context) {
                return MaterialApp(
                  title: 'MySignup',
                  theme: ThemeData(

                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                    useMaterial3: true,
                  ),
                  home: const editprofile(title: 'MySignup'),
                );
              }
            }

            class editprofile extends StatefulWidget {
              const editprofile({super.key, required this.title});

              final String title;

              @override
              State<editprofile> createState() => _editprofileState();
            }

            class _editprofileState extends State<editprofile> {
              _editprofileState(){
                _get_data();
              }

              String gender = "Male";
              File? uploadimage;
              TextEditingController  nameController=TextEditingController();
              TextEditingController  emailController=TextEditingController();
              TextEditingController  phoneController=TextEditingController();
              TextEditingController  dobController=TextEditingController();
              TextEditingController  genderController=TextEditingController();
              TextEditingController  placeController=TextEditingController();
              TextEditingController  pinController=TextEditingController();
              TextEditingController  postController=TextEditingController();
              TextEditingController  districtController=TextEditingController();





              // Future<void> chooseImage() async {
              //   // final choosedimage = await ImagePicker().pickImage(source: ImageSource.gallery);
              //   //set source: ImageSource.camera to get image from camera
              //   setState(() {
              //     // uploadimage = File(choosedimage!.path);
              //   });
              // }




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
                              : Image.network(uphoto_,height: 150),
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
                              controller: dobController,
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
                                    String sd='${dt!.year}-${dt.month}-${dt.day}';
                                setState(() {
                                  dobController.text=sd;
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
                              controller: placeController,

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
                              controller: postController,

                              decoration: InputDecoration(border: OutlineInputBorder(),label: Text("Post")),
                            ),
                          ),       Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: districtController,

                              decoration: InputDecoration(border: OutlineInputBorder(),label: Text("District")),
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {

                              _send_data() ;

                            },
                            child: Text("editprofile"),
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
                String uplace=placeController.text;
                String upin=pinController.text;
                String upost=postController.text;
                String udistrict=districtController.text;

                SharedPreferences sh = await SharedPreferences.getInstance();
                String? url = sh.getString('url');
                String? lid = sh.getString('lid');

                if (url == null) {
                  Fluttertoast.showToast(msg: "Server URL not found.");
                  return;
                }

                final uri = Uri.parse('$url/user_editprofile_post/');
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
                request.fields['lid'] = lid.toString();

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
                      builder: (context) =>ViewProfilePage(title: '',),));
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
              String uphoto_ = '';
              void _get_data() async{



                SharedPreferences sh = await SharedPreferences.getInstance();
                String url = sh.getString('url').toString();
                String img_url = sh.getString('img_url').toString();
                String lid = sh.getString('lid').toString();
                print(url);

                final urls = Uri.parse('$url/user_viewprofile_post/');
                try {
                  final response = await http.post(urls, body: {
                    'lid':lid



                  });
                  if (response.statusCode == 200) {
                    String status = jsonDecode(response.body)['status'];
                    if (status=='ok') {
                      String name=jsonDecode(response.body)['name'];
                      String email=jsonDecode(response.body)['email'];
                      String phone=jsonDecode(response.body)['phone'];
                      String dob=jsonDecode(response.body)['dob'];
                      String gend=jsonDecode(response.body)['gender'];
                      String place=jsonDecode(response.body)['place'];
                      String pin=jsonDecode(response.body)['pin'];
                      String post=jsonDecode(response.body)['post'];
                      String district=jsonDecode(response.body)['district'];
                      String photo=img_url+jsonDecode(response.body)['photo'];

                      setState(() {

                        nameController.text= name;
                        emailController.text= email;
                        phoneController.text= phone;
                        dobController.text= dob;
                        gender= gend;
                        placeController.text= place;
                        pinController.text= pin;
                        postController.text= post;
                        districtController.text= district;
                        uphoto_= photo;
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

