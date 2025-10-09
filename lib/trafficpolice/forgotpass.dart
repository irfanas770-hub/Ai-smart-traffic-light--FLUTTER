
import 'package:flutter/material.dart';

void main(){
 runApp(myapp());
}
class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:forgotpass() ,);
  }
}
class forgotpass extends StatefulWidget {
  const forgotpass({super.key});

  @override
  State<forgotpass> createState() => _forgotpassState();
}

class _forgotpassState extends State<forgotpass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blue,
        title: Text("Forget Password"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(decoration: InputDecoration(labelText: "Email",border: OutlineInputBorder()),),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            print("submit");
          }, child: Text("submit"))
        ],
      ),
    );
  }
}

