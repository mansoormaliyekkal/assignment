import 'dart:convert';

import 'package:ams/models/ForgotPassword.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => ForgotPassword(),
    );
  }

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _forgotPassword = new TextEditingController();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email;

  Future<void> fetchNews() async {
    var client = new http.Client();

    setState(() {
      _isLoading = true;
    });
    String url =
        "https://www.adevole.com/clients/attendance_app/mobile/forgot_password.php?email=${_forgotPassword.text}";
    print("URL is $url");
    print("Url is $url");
    final response = await client.put(Uri.parse(url));
    print("Task Response status: ${response.statusCode}");
    print("Task Response body: ${response.body}");
    if (response.statusCode == 200) {
      var jsonData = ForgotPassModel.fromJson(json.decode(response.body));
      print(jsonData);
      if (jsonData.responseStatus == 1) {
        showCommonToast("${jsonData.message}");
        Navigator.of(context).pop();
      } else if (jsonData.responseStatus == 0) {
        showCommonToast("${jsonData.errorMessage}");
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      showCommonToast("There is some problem in Fetching data");
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Forgot Password"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _forgotPassword,
                  decoration:
                      const InputDecoration(labelText: 'Enter your Email id'),
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  onSaved: (String val) {
                    _email = val;
                  },
                ),
                /*CommonTextField(
                controller: _forgotPassword,
                label: "Enter your Email id",
                validator: (val){

                },
              ),*/
                SizedBox(
                  height: 10.0,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : commonButton("Submit", () {
                        if (_formKey.currentState.validate()) {
                          // No any error in validation
                          _formKey.currentState.save();
                          fetchNews();
                        } else {
                          showCommonToast("Please enter valid email Id");
                        }
                      })
              ],
            ),
          ),
        ));
  }
}
