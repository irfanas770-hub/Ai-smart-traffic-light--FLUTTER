
import 'package:flutter/material.dart';

void main(){
  runApp(myapp());
}
class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: changepassword()
    );
  }
}
class changepassword extends StatefulWidget {
  const changepassword({super.key});

  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Change Password"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(decoration: InputDecoration(labelText: "Password",border:OutlineInputBorder()),),
          SizedBox(height: 20,),
          TextField(decoration: InputDecoration(labelText: "New Password",border:OutlineInputBorder()),),
          SizedBox(height: 30,),
          TextField(decoration: InputDecoration(labelText: "Confirm Password",border:OutlineInputBorder()),),
          SizedBox(height: 30,),
          ElevatedButton(onPressed: (){
            print("change");
          }, child: Text("change"))
        ],
      ),
      
    );
  }
}

