import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:mtech/auth.dart';

void main() {
  runApp(MaterialApp(
    home: Auth(),
  ));
}

class MyApp extends StatefulWidget {
  final User authenticateuser;
  Function logout;
  MyApp(this.authenticateuser,this.logout);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState(authenticateuser,logout);
  }
}

class MyAppState extends State<MyApp> {
  User authenticateuser;
  Function logout;

  MyAppState(this.authenticateuser,this.logout);
  String name;
  String email;
  String address;
  int number;
  Map<String, dynamic> userdata = {
    'Name': '',
    'email': '',
    'adress': '',
    'number': '',
    'random_num': ''
  };
  Map<String, dynamic> usernotauth = {
    'email': '',
    'random_num': '',
  };

  void _submitform(String name, String email, String adress, int number) async {
    int randomNumber = math();

    userdata = {
      'Name': name,
      'email': email,
      'adress': adress,
      'number': number,
      'random_num': randomNumber
    };
    usernotauth = {
      'email': email,
      'random_num': randomNumber,
    };
    http.Response response = await http.post(
        'https://macrotech-44e5c.firebaseio.com/Users.json?auth=${authenticateuser.idToken}',
        body: json.encode(userdata));
    http.post('https://macrotech-44e5c.firebaseio.com/Usersnotauth.json',
        body: json.encode(usernotauth));
    Map<String, dynamic> responsedata = jsonDecode(response.body);
    if (responsedata.containsKey('name')) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("UserInfoEntered"),
              title: Text("RandomNumber${randomNumber.toString()}"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    print(responsedata);
  }

  int math() {
    var rng = new Random();
    int randomNumber = rng.nextInt(100000);
    return randomNumber;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      appBar: AppBar(
        title: Text('Form Page'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (String value) {
                    email = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Adress',
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (String value) {
                    address = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (String value) {
                    number = int.parse(value);
                  },
                ),
                RaisedButton(
                  child: Text("Submit Form"),
                  onPressed: () {
                    _submitform(name, email, address, number);
                  },
                ),
                RaisedButton(child: Text("Logout"),onPressed: (){
                  logout();
                
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Auth()));
                  
                },)
              ],
            ),
          )
        ],
      ),
    );
  }
}
