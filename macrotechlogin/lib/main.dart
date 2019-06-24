import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

enum Authclient {
  Signup,
  Login,
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class Client {
  String email;
  int number;
  String password;
}

class MyAppState extends State<MyApp> {
  List<Client> clientInfo = [];
  bool yes = false;
  Authclient authclient = Authclient.Signup;

  String email;
  String password;

  GlobalKey<FormState> authkey = GlobalKey<FormState>();
  int number;
  void fetchdata(String email, int number, String password) {
    http
        .get('https://macrotech-44e5c.firebaseio.com/Usersnotauth.json')
        .then((http.Response response) {
      Map<String, dynamic> productslist = json.decode(response.body);
      productslist.forEach((String id, dynamic productdata) {
        Client user = Client();
        user.email = productdata['email'];
        user.number = productdata['random_num'];
        clientInfo.add(user);
      });
      print(json.decode(response.body));
      check(email, number, password);
    });
  }

  Widget check(String email, int number, String password) {
    for (int i = 0; i < clientInfo.length; i++) {
      if (clientInfo[i].email == email && clientInfo[i].number == number) {
        yes = true;
        print(clientInfo.length);
      }
    }
    authenticate(yes, email, password);
    return Container();
  }

  void authenticate(bool yes, String email, String password) async {
    Map<String, dynamic> successInformtion;
    if (yes) {
      successInformtion = await signup(email, password);
      if (successInformtion['success']) {
        print('authenticate');
      }
      // print('authenticate');
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text(successInformtion['message']),
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
  }
  void loginfunction(String email,String password)async{
    Map<String,dynamic> successInformation;
      successInformation= await login(email, password);
     if (successInformation['success']) {
        print('Login Sucessfull');
      }
      // print('authenticate');
      else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('An error occured'),
                content: Text(successInformation ['message']),
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
      haserror = true;
      message = 'Authentication successeded';
    } else if (responsedata['error']['message'] == 'EMAIL_NOT_FOUND') {
      haserror = false;
      message = 'Email not exists';
    }
     else if (responsedata['error']['message'] == 'INVALID_PASSWORD') {
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
        title: Text('Authentication'),
      ),
      body: Form(
        key: authkey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration:
                  InputDecoration(hintText: 'Enter Email ', labelText: 'Email'),
              onSaved: (String value) {
                email = value;
              },
            ),
            authclient == Authclient.Signup
                ? TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Enter Number ', labelText: 'number'),
                    onSaved: (String value) {
                      number = int.parse(value);
                    },
                  )
                : Container(),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  hintText: 'Enter Password ', labelText: 'Password'),
              onSaved: (String value) {
                password = value;
              },
            ),
            FlatButton(
              child: Text(authclient == Authclient.Login
                  ? 'Switch to Signup'
                  : "Switch to Login"),
              onPressed: () {
                setState(() {
                  authclient == Authclient.Login
                      ? authclient = Authclient.Signup
                      : authclient = Authclient.Login;
                });
              },
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                authkey.currentState.save();
                authclient == Authclient.Signup
                    ? fetchdata(email, number, password)
                    : loginfunction(email, password);
              },
            )
          ],
        ),
      ),
    );
  }
}
