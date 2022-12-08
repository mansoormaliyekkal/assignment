import 'dart:async';

import 'package:ams/screens/HomePage.dart';
import 'package:ams/screens/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPreferences sharedPreferences;

  //Mark the user status as true or false
  Future setUserStatus(bool status) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('loginStatus', status);
  }

  //save check In time and address
  Future<void> saveCheckInInfo(String address, String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('address', address);
    prefs.setString('time', time);
  }

  clearInfo() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('address');
    prefs.remove('time');
  }

  //Clear the sharedPreferences on logout
  Future clearUserDataFromSF() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('loginStatus');
    sharedPreferences.remove('userId');
    sharedPreferences.remove('userrole_id');
    sharedPreferences.remove('useremail_id');
    sharedPreferences.remove('userphone_no');
    sharedPreferences.remove('useremp_id');
    sharedPreferences.remove('usersupervisor_id');
    sharedPreferences.remove('userdoj');
    sharedPreferences.remove('userforgot_pass_key');
    sharedPreferences.remove('userToken');
    sharedPreferences.remove('time');
    sharedPreferences.remove('address');
  }

  Future setCheckInStatus(int status) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt("status", status);
  }

  //Set the user token
  Future setUserData(id, roleId, emailId, phoneNo, empId, supervisorId, doj,
      forgotPassKey, userToken, name) async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('userId', id);
    sharedPreferences.setInt('userrole_id', roleId);
    sharedPreferences.setString('useremail_id', emailId);
    sharedPreferences.setString('userphone_no', phoneNo);
    sharedPreferences.setString('useremp_id', empId);
    sharedPreferences.setInt('usersupervisor_id', supervisorId);
    sharedPreferences.setString('userdoj', doj);
    sharedPreferences.setString('userforgot_pass_key', forgotPassKey);
    sharedPreferences.setString('userToken', userToken);
    sharedPreferences.setString('name', name);
  }

  //Get the user token
  Future getToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String tokenId = sharedPreferences.getString('userToken' ?? false);
    int userId = sharedPreferences.getInt('userId' ?? false);
    String userEmailId = sharedPreferences.getString('userEmailId' ?? false);
    String userPhoneNo = sharedPreferences.getString('userPhoneNo' ?? false);
    print(
        "Data Stored in SF $tokenId \n $userId\n $userEmailId\n $userPhoneNo");
    return tokenId;
  }

  Future getUserName() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String name = sharedPreferences.getString('name' ?? false);
    return name;
  }

  Future getUserEmail() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String email = sharedPreferences.getString('useremail_id' ?? false);
    return email;
  }

  // Get the user status
  Future userStatus(BuildContext context) async {
    sharedPreferences = await SharedPreferences.getInstance();
    bool login = (sharedPreferences.getBool('loginStatus') ?? false);

    if (login) {
      Navigator.of(context).pushReplacement(HomePage.route());
      print('Login Status $login');
    } else {
      Navigator.of(context).pushReplacement(LoginPage.route());
      //sharedPreferences.setBool('_login', false);
    }
  }
}
