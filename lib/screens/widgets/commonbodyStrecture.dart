import 'package:ams/resource/sharedPref.dart';
import 'package:ams/screens/AttendancePage.dart';
import 'package:ams/screens/LoginPage.dart';
import 'package:ams/screens/NotificationsPage.dart';
import 'package:ams/screens/TaskPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _email = '';
String _name = '';

class CommonBodyStructure extends StatefulWidget {
  final List<Widget> actions;
  final Widget child;
  final String text;
  final Widget fab;

  const CommonBodyStructure(
      {Key key, @required this.child, this.text, this.actions, this.fab})
      : super(key: key);

  @override
  _CommonBodyStructureState createState() => _CommonBodyStructureState();
}

class _CommonBodyStructureState extends State<CommonBodyStructure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          widget.text,
          style: TextStyle(color: Colors.indigo),
        ),
        actions: widget.actions,
      ),
      drawer: (widget.text == 'Home Page') ? commonDrawer(widget.text) : null,
      body: widget.child,
      floatingActionButton: widget.fab,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNameEmail();
  }

  _loadNameEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = (prefs.getString('useremail_id') ?? '');
      _name = (prefs.getString('name') ?? '');
    });
  }

  //Common Drawer
  Widget commonDrawer(String title) {
    return Drawer(
      elevation: 3.0,
      child: ListView(
        children: <Widget>[
          ListTile(),
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: 16),
                CircleAvatar(
                  maxRadius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_outline),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _name,
                      textScaleFactor: 1.5,
                      style: TextStyle(color: Colors.black),
                    ),
                    Text(
                      _email,
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                )
//                ListTile(
//                  title: Text(_name,
//                      style: TextStyle(
//                          color: Colors.black,
//                          fontWeight: FontWeight.bold,
//                          fontSize: 20.0)),
//                  subtitle: Text(
//                    _email,
//                    style: TextStyle(
//                        color: Colors.black, fontStyle: FontStyle.italic),
//                  ),
//                ),
              ],
            ),
          ),
//          UserAccountsDrawerHeader(
//            accountName: Text(_name,
//                style: TextStyle(
//                    color: Colors.black,
//                    fontWeight: FontWeight.bold,
//                    fontSize: 20.0)),
//            decoration: BoxDecoration(color: Colors.white),
//            accountEmail: Text(
//              _email,
//              style:
//                  TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
//            ),
//            currentAccountPicture: CircleAvatar(
//              backgroundColor: Colors.black,
//              child: Icon(Icons.person),
//            ),
//          ),
          SizedBox(height: 10),
          ListTile(
            title: Text("Task"),
            leading: Image.asset(
              "Images/icon/list.png",
              height: 24,
            ),
            onTap: () {
              Navigator.pop(context);
              if (title != 'Task') Navigator.push(context, TaskPage.route());
            },
          ),
          ListTile(
              title: Text("Attendance"),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.pop(context);
                if (title != 'Attendance Details')
                  Navigator.push(context, AttendancePage.route());
              }),
          /* ListTile(
            title: Text("Contack Us"),
            leading: Icon(Icons.add_call),
            onTap: () {},
          ),
          ListTile(
            title: Text("About Us"),
            leading: Icon(Icons.contact_mail),
            onTap: () {
              // Navigator.of(context).pop();
            },
          ),*/
          ListTile(
              title: Text("Notifications"),
              leading: Icon(Icons.notifications_active),
              onTap: () {
                Navigator.pop(context);
                if (title != 'Notifications')
                  Navigator.push(context, NotificationPage.route());
              }),
          ListTile(
            title: Text("Logout"),
            leading: Image.asset("Images/icon/logout.png", height: 24),
            onTap: () {
              SharedPref().clearUserDataFromSF();
              Navigator.pushReplacement(context, LoginPage.route());
            },
          ),
        ],
      ),
    );
  }
}
