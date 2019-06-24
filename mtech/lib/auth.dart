import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mtech/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthUser { SignIn, LogIn }

class Auth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AuthState();
  }
}

class User {
  String email;
  String password;
  String id;
  String idToken;
  User({this.email, this.password, this.id, this.idToken});
}

class AuthState extends State<Auth> {
  void initState(){

    autoLogin();
    super.initState();
  }
  GlobalKey<FormState> authKey = GlobalKey<FormState>();
  TextEditingController passwordcontroller = TextEditingController();
  String email;
  String password;
  String confirmPassword;
  AuthUser authuser = AuthUser.LogIn;
  User authenticateUser = User();
  void autoLogin()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
   String token= pref.getString('token');
   if(token!=null){
     final String email=pref.getString('email');
     final String id=pref.getString('localId');
     final String password=pref.getString('password');
     User authenticateUser=User(email: email,id: id,password: password,idToken: token);
     Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MyApp(authenticateUser,logout)));
     
   }

  }
  void logout()async{
    authenticateUser=null;
    SharedPreferences pref=await SharedPreferences.getInstance();
    pref.remove('token');
    pref.remove('email');
    pref.remove('localId');
    pref.remove('password');
  }
  void loginfunction(String email, String password) async {
    Map<String, dynamic> successInformation;
    successInformation = await login(email, password);
    if (successInformation['success']) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MyApp(authenticateUser,logout)));
      print('Login Sucessfull');
    }
    // print('authenticate');
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An error occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  void signUpfunction(String email, String password) async {
    Map<String, dynamic> successInformation;
    successInformation = await signup(email, password);
    if (successInformation['success']) {
      print('SignUp sucessfully');
    }
    // print('authenticate');
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('An error occured'),
              content: Text(successInformation['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Map<String, dynamic> autodata = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDpBWXQ_w-W8BvVGV48rkuFL4qDtTeORfM',
        body: jsonEncode(autodata),
        headers: {"Content-Type": "application/json"});
    Map<String, dynamic> responsedata = json.decode(response.body);
    bool haserror = false;
    String message = 'Somethimg went wrong.';
    if (responsedata.containsKey('idToken')) {
      if (responsedata['email'] == 'admin@gmail.com') {
        haserror = true;
        message = 'Authentication successeded';
        authenticateUser = User(
            email: email,
            id: responsedata['localId'],
            password: password,
            idToken: responsedata['idToken']);
            SharedPreferences pref=await SharedPreferences.getInstance();
            pref.setString('token', responsedata['idToken']);
            pref.setString('email', email);
            pref.setString('localId', responsedata['localId']);
            pref.setString('password', password);
      }
      else{
        haserror=false;
        message='Not autheriseduser';
      }
    } else if (responsedata['error']['message'] == 'EMAIL_NOT_FOUND') {
      haserror = false;
      message = 'Email not exists';
    } else if (responsedata['error']['message'] == 'INVALID_PASSWORD') {
      haserror = false;
      message = 'Invalid Password';
    }

    print(response.body);
    return {'success': haserror, 'message': message};
  }

  Future<Map<String, dynamic>> signup(String email, String password) async {
    final Map<String, dynamic> autodata = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDpBWXQ_w-W8BvVGV48rkuFL4qDtTeORfM',
        body: json.encode(autodata),
        headers: {'Content-Type': 'application/json'});
    Map<String, dynamic> responsedata = json.decode(response.body);
    bool haserror = false;
    String message = 'Somethimg went wrong.';
    if (responsedata.containsKey('idToken')) {
      haserror = true;
      User authenticateUser = User();
      authenticateUser.email = email;
      authenticateUser.idToken = responsedata['idToken'];
      authenticateUser.id = responsedata['localId'];
      authenticateUser.password = password;

      message = 'Login Successful successeded';
    } else if (responsedata['error']['message'] == 'EMAIL_EXISTS') {
      haserror = false;
      message = 'Email already exists';
    }

    print(response.body);
    return {'success': haserror, 'message': message};
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication"),
      ),
      body: Form(
        key: authKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              validator: (String value) {
                if (value.isEmpty) {
                  return 'enter the email';
                }
              },
              decoration: InputDecoration(
                hintText: 'Enter Email ',
                labelText: 'Email',
              ),
              onSaved: (String value) {
                email = value;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: 'Enter Password ', labelText: 'Password'),
              validator: (String value) {
                if (value.isEmpty || value.length < 8) {
                  return 'Enter the password and should contain atleast 8 char';
                }
              },
              controller: passwordcontroller,
              onSaved: (String value) {
                password = value;
              },
            ),
            authuser == AuthUser.LogIn
                ? Container()
                : TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintText: 'Enter Confirm Password ',
                        labelText: 'Enter Confirm Password'),
                    validator: (String value) {
                      if (value != passwordcontroller.text) {
                        return 'Password does not match';
                      }
                    },
                    onSaved: (String value) {
                      confirmPassword = value;
                    },
                  ),
            FlatButton(
              child: Text(authuser == AuthUser.LogIn
                  ? 'Swith to sign up'
                  : 'Switch to LogIn'),
              onPressed: () {
                setState(() {
                  authuser == AuthUser.LogIn
                      ? authuser = AuthUser.SignIn
                      : authuser = AuthUser.LogIn;
                });
              },
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                authKey.currentState.save();
                authKey.currentState.validate();
                setState(() {
                  authuser == AuthUser.LogIn
                      ? loginfunction(email, password)
                      : signUpfunction(email, password);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
