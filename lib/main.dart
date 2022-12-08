import 'package:ams/resource/sharedPref.dart';
import 'package:ams/screens/AttendancePage.dart';
import 'package:ams/screens/HomePage.dart';
import 'package:ams/screens/LoginPage.dart';
import 'package:flutter/material.dart';

/*
void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
  showcommonToast("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
}

Future<void> main() async {
  final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);
}*/

void main() async {
  runApp(MyApp());
  await SharedPref().clearInfo();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          '/HomePage': (BuildContext context) => HomePage(),
          '/AttendancePage': (BuildContext context) => AttendancePage()
        },
        theme: ThemeData(
            fontFamily: 'Comfortaa',
            primarySwatch: Colors.indigo,
            primaryColor: Colors.indigo,
            accentColor: Colors.indigoAccent,
            textTheme: TextTheme(button: TextStyle(color: Colors.white)),
            iconTheme: IconThemeData(color: Colors.indigoAccent),
            buttonTheme: ButtonThemeData(
                buttonColor: Colors.indigoAccent,
                textTheme: ButtonTextTheme.primary)),
        home: SplashScreen());
  }
}
