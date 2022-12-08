import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => NotificationPage(),
    );
  }

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
      text: "Notifications",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Text(
            "Notifications",
          )),
        ],
      ),
    );
  }
}
