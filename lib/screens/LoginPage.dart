import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ams/models/LoginModel.dart';
import 'package:ams/resource/sharedPref.dart';
import 'package:ams/screens/ForgotPassword.dart';
import 'package:ams/screens/HomePage.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  static const routeName = "/SplashScreen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String _firebaseToken;

  @override
  void initState() {
    super.initState();

    firebaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called");
    }, onMessage: (Map<String, dynamic> msg) {
      print("onMessage called");
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called");
    });

    firebaseMessaging.getToken().then((token) {
      fireBaseToken(token);
    });

    Timer(Duration(seconds: 2), () {
      SharedPref().userStatus(context);
    });
  }

  fireBaseToken(String token) {
    _firebaseToken = token;
    setState(() {});

    print("Token is $_firebaseToken");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Scaffold(
          body: Center(
            // $firebasetoken
            child: Text(
              "Attendance \n Management \n System",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        ));
  }
}

class LoginPage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => LoginPage(),
    );
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  var loginForm = GlobalKey<FormState>();
  bool _isLoading = false;
  bool obscureText = true;

  FirebaseMessaging fireBaseMessaging = FirebaseMessaging();
  String _fireBaseToken;

  bool internetConn = true;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  checkConnection() {
    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      //_connectionState = result.toString();
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        setState(() {
          internetConn = true;
        });
        print("Internet Connection state is $result");
      } else if (result == ConnectivityResult.none) {
        setState(() {
          internetConn = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnection();

    fireBaseMessaging.configure(onLaunch: (Map<String, dynamic> msg) {
      print("onLaunch called $msg");
    }, onMessage: (Map<String, dynamic> msg) {
      print("onMessage called  $msg");
    }, onResume: (Map<String, dynamic> msg) {
      print("onResume called $msg");
    });

    fireBaseMessaging.getToken().then((token) {
      fireBaseToken(token);
    });
  }

  fireBaseToken(String token) {
    _fireBaseToken = token;
    setState(() {});

    print("Token is $_fireBaseToken");
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _userValidation() {
    var url = "http://adevole.com/clients/attendance_app/mobile/login.php";

    var client = new http.Client();
    setState(() {
      _isLoading = true;
    });
    client.post(url, body: {
      "email_id": _userNameController.text,
      "password": _passwordController.text,
      "fcm_id": _fireBaseToken
    }).then((response) {
      print("Program Response status: ${response.statusCode}");
      print("Program Response body: ${response.body}");
      if (response.statusCode == 200) {
        try {
          // If the call to the server was successful, parse the JSON
          var jsonData = LoginModel.fromJson(json.decode(response.body));
          print(jsonData);
          if (jsonData.responseStatus == 1) {
            var msgdata =
            MessageResponseModel.fromJson(json.decode(response.body));
            var loginToken = jsonData.messageResponseModel.token;
            print("Decoded json data is ${msgdata.token}");
            print("Status code is ${jsonData.responseStatus}");
            print("Login Token $loginToken");

            SharedPref().setUserStatus(true);
            SharedPref().setUserData(
                jsonData.messageResponseModel.id,
                jsonData.messageResponseModel.roleId,
                jsonData.messageResponseModel.emailId,
                jsonData.messageResponseModel.phoneNo,
                jsonData.messageResponseModel.empId,
                jsonData.messageResponseModel.supervisorId,
                jsonData.messageResponseModel.doj,
                jsonData.messageResponseModel.forgotPassKey,
                jsonData.messageResponseModel.token,
                jsonData.messageResponseModel.name);
            print("Encrypted Login Token ${SharedPref().getToken()}");
            Navigator.of(context).pushReplacement(HomePage.route());
            //sharedPreferences.setBool('loginStatus', true);
            showCommonToast("Login success  ");
            setState(() {
              _isLoading = false;
            });
          } else if (jsonData.responseStatus == 0) {
            // If that call was not successful, throw an error.
            showCommonToast("Invalid User.");
          }
          else{
            throw Exception('Error occured');
          }
          setState(() {
            _isLoading = false;
          });
          return null;
        } catch (exception) {
          print(exception);
          showCommonToast("invalid user.");
          setState(() {
            _isLoading = false;
          });
//          showColoredToast("There is some problem while login");
          if (exception.toString().contains('SocketException')) {
            return 'NetworkError';
          } else {
            return null;
          }
        }
      } else {
        // If that call was not successful, throw an error.
        showCommonToast("Please enter the valid username or password.");
        throw Exception('Failed to load post');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () => willPop(context),
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: internetConn
              ? SizedBox(
                  width: 0.0,
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 18.0),
                  child: CustomFloatingButton(),
                ),
          body: Stack(
            children: <Widget>[
              Center(
                child: new Image.asset(
                  'Images/AMSlogin.jpg',
                  width: size.width,
                  height: size.height,
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(
                  child: Form(
                    key: loginForm,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          /*Image.asset(
                              "Images/AutoAquaLogo.png",
                              height: 170.0,
                              width: 170.0,
                            ),*/
                          Icon(
                            Icons.account_circle,
                            size: 90.0,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: _userNameController,
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Please enter the username.";
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
//                                prefixIcon: Icon(
//                                  Icons.email,
//                                  color: Colors.black,
//                                ),
                                labelText: "Username"),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            validator: (val) {
                              if (val.isEmpty) {
                                return "Please enter the password.";
                              }
                              return null;
                            },
                            decoration: new InputDecoration(
                                suffix: IconButton(
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                ),
//                              hintText: "Password",
//                                alignLabelWithHint: true,
                                labelText: 'Password'),
                            keyboardType: TextInputType.text,
                            obscureText: obscureText,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(child: SizedBox()),
                              FlatButton(
                                  onPressed: () => Navigator.push(
                                      context, ForgotPassword.route()),
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                            ],
                          ),
                          _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : commonButton("LOGIN", () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  if (loginForm.currentState.validate()) {
                                    _userValidation();
                                    //Navigator.of(context).pushReplacement(HomePage.route());
                                  } else {
//                                    showColoredToast("There is some problem with login");
                                  }
                                } //Navigator.of(context).pushReplacement(HomePage.route())
                                  ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
