import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//Close the App on back press
Future<bool> willPop(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Do you really want to exit"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("No")),
              FlatButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Yes")),
            ],
          ));
}

//Common Text Widget for DataColumn
Widget commonText(name) {
  return Text(
    name,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
  );
}

//Common Button
Widget commonButton(String label, VoidCallback onPressed) {
  return RaisedButton(
      textColor: Colors.white,
      color: Colors.indigoAccent,
      child: new Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(8)),
      onPressed: onPressed);
}

void showCommonToast(String errorMessage) {
  Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 16.0);
}

Widget noConnection() {
  return Image.asset("Images/NoConnection.jpg"); // return Column(
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   crossAxisAlignment: CrossAxisAlignment.center,
  //   children: <Widget>[
  //     Icon(
  //       Icons.perm_scan_wifi,
  //       color: Colors.black,
  //       size: 150.0,
  //     ),
  //     Text(
  //       "Whoops!",
  //       textAlign: TextAlign.center,
  //       style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
  //     ),
  //     Text(
  //       "Re-connect your app to access this part of app!",
  //       textAlign: TextAlign.center,
  //       style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
  //     )
  //   ],
  // );
}

//Custom floating action button

//Custom Floating Button
class CustomFloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Colors.red,
      splashColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Text(
          "NO INTERNET CONNECTION",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      onPressed: null,
      shape: const StadiumBorder(),
    );
  }
}
