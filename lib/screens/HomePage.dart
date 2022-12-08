import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ams/models/CheckInOutModel.dart';
import 'package:ams/models/checkStatusModel.dart';
import 'package:ams/resource/sharedPref.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddTask.dart';
import 'TaskPage.dart';

class HomePageRoute extends MaterialPageRoute {
  HomePageRoute()
      : super(
          builder: (context) => HomePage(),
        );
}

class HomePage extends StatefulWidget {
  static Route<dynamic> route() {
    return HomePageRoute();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _latitude;
  double _longitude;
  String address;
  String _email;
  String _name;
  Duration _time = Duration(seconds: 00);
  bool checkIn = false;
  String checkInAddress;
  Timer _timer;
  StreamController _timerController;

  Stream get _timerStream => _timerController.stream;

//  Timer _timer = Timer.periodic(Duration(seconds: 5), (_timer) {
//    _time=Duration;
//  });
  static const platform = const MethodChannel('flutter.native/locationHelper');

//  Future<void> getCurrentLoation() async {
//    Position position;
//    try {
//      position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//      _latitude = position.latitude;
//      _longitude = position.longitude;
//      List<Placemark> placeMarkAdd = await Geolocator().placemarkFromCoordinates(_latitude, _longitude);
//      Placemark placemark = placeMarkAdd[0];
//      address = "${placemark.name}, ${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
//      print(
//          "address = ${placemark.name}, ${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}");
//    } on PlatformException {
//      position = null;
//    }
//  }

  openLocationSetting() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }

//   checkLocation() async {
//    var geoLocator = Geolocator();
//    var status = await geoLocator.checkGeolocationPermissionStatus();
//
//    if (status == GeolocationStatus.denied) {
//      // Take user to permission settings
//      print("location denied");
//      _showDialogforlocationPermission();
////      showColoredToast("Denied! Please enable the location");
//    } else if (status == GeolocationStatus.disabled) {
//      // Take user to location page
//      print("location disabled");
////      showColoredToast("disabled! Please enable the location");
//      _showDialog();
//      //openLocationSetting();
//    } else if (status == GeolocationStatus.restricted) {
//      // Restricted
//      print("location restricted");
////      showColoredToast("Restrected! Please enable the location");
//    } else if (status == GeolocationStatus.unknown) {
//      // Unknown
//      print("location unknown");
////      showColoredToast("There is some problem");
//    } else if (status == GeolocationStatus.granted) {
//      // Permission granted and location enabled
////      showColoredToast("Done");
//      getCurrentLoation();
//    }
//  }

  /*void _showDialogforlocationPermission() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SimpleDialog(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  "LOCATION ACCESS",
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black12,
                    maxRadius: 90.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "Images/locationIcon.png",
                        width: 150.0,
                        height: 150.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "If you would like to able to access full functionality of app. Please allow location access.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                MaterialButton(
                    height: 40.0,
                    minWidth: 190.0,
                    elevation: 10.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Allow",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    color: Colors.green,
                    onPressed: () => getCurrentLoation()),
                SizedBox(
                  height: 10.0,
                ),
                OutlineButton(
                    child: Text(
                      "Not Now",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context)),
              ],
            )
          ],
        );
      },
    );
  }*/

//  void _showDialog() {
//    // flutter defined function
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return SimpleDialog(
//          children: <Widget>[
//            Column(
//              children: <Widget>[
//                Text(
//                  "LOCATION ACCESS",
//                  style: TextStyle(
//                    fontSize: 25.0,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//                Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: CircleAvatar(
//                    backgroundColor: Colors.black12,
//                    maxRadius: 90.0,
//                    child: Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Image.asset(
//                        "Images/locationIcon.png",
//                        width: 150.0,
//                        height: 150.0,
//                      ),
//                    ),
//                  ),
//                ),
//                SizedBox(
//                  height: 10.0,
//                ),
//                Text(
//                  "Allow location access for functioning of app.",
//                  textAlign: TextAlign.center,
//                  style: TextStyle(
//                    fontSize: 20.0,
//                    fontWeight: FontWeight.bold,
//                  ),
//                ),
//                SizedBox(
//                  height: 10.0,
//                ),
//                MaterialButton(
//                    height: 40.0,
//                    minWidth: 190.0,
//                    elevation: 10.0,
//                    child: Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: Text(
//                        "Allow",
//                        style: TextStyle(
//                          color: Colors.white,
//                          fontSize: 20.0,
//                        ),
//                      ),
//                    ),
//                    color: Colors.green,
//                    onPressed: () => openLocationSetting()),
//                SizedBox(
//                  height: 10.0,
//                ),
//                OutlineButton(
//                    child: Text(
//                      "Close",
//                      style: TextStyle(
//                        color: Colors.black,
//                        fontSize: 20.0,
//                      ),
//                    ),
//                    onPressed: () => Navigator.pop(context)),
//              ],
//            )
//          ],
//        );
//      },
//    );
//  }

  //CheckIn Method
  saveCheckInStatus(int flag, String address) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    print("Data Stored in SF $tokenId \n $userId ");
    /*${address}*/
    String url =
        "http://adevole.com/clients/attendance_app/mobile/checkin_out.php?user_id=$userId&security_key=$tokenId&lat=$_latitude&long=$_longitude&address=$address&flag=$flag";
    print("Url is $url");
    final response = await http.put(url);
    if (response.statusCode == 200) {
      try {
        var jsonData = CheckInOutModel.fromJson(json.decode(response.body));

        if (jsonData.responseStatus == 1) {
          setState(() {
            checkIn = true;
          });
        } else if (jsonData.responseStatus == 2) {
          setState(() {
            checkIn = false;
          });
        } else if (jsonData.responseStatus == 0) {
          showCommonToast("error occured");
        } else if (jsonData.responseStatus == 9) {
          showCommonToast("you are checked in Already for today.");
          setState(() {
            checkIn = true;
          });
        } else if (jsonData.responseStatus == 10) {
//            SharedPref().setCheckInStatus(jsonData.ResponseStatus);
          showCommonToast("you have already checked out for the day");
          setState(() {
            checkIn = false;
          });
        }
      } catch (exception) {
        print(exception);
//        showColoredToast("There is some problem while login");
        if (exception.toString().contains('SocketException')) {
          return 'NetworkError';
        } else {
          return null;
        }
      }
    } else {
//      showColoredToast("There is some problem in Fetching data");
    }
//    }else{
//      showToast("you are already checked in");
//    }
  }

  //CheckOut Method
  saveCheckOutStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    print("Data Stored in SF $tokenId \n $userId ");
    String url =
        "http://adevole.com/clients/attendance_app/mobile/checkin_out.php?user_id=$userId&security_key=$tokenId&lat=$_latitude&long=$_longitude&address=$address&flag=2";
    print("Url is $url");
//    if(sharedPreferences.get("status")!= 10){
    final response = await http.put(url);
    print("Task Response status: ${response.statusCode}");
    print("Task Response body: ${response.body}");
    if (response.statusCode == 200) {
      try {
        // If the call to the server was successful, parse the JSON
        var jsonData = CheckInOutModel.fromJson(json.decode(response.body));
        if (jsonData.responseStatus == 1) {
//          showColoredToast(jsonData.Message);
          print("Status code is ${jsonData.responseStatus}");
          print("Check Message is ${jsonData.message}");
          setState(() {
            checkIn = false;
          });
          showCommonToast("Checked out successfully");
//            SharedPref().setCheckInStatus(10);
          //sharedPreferences.setBool('loginStatus', true);
        } else if (jsonData.responseStatus == 0) {
          // If that call was not successful, throw an error.
          showCommonToast("error Occured");
          showCommonToast("You are already checkedOut");
        } else if (jsonData.responseStatus == 10) {
          setState(() {
            checkIn = false;
          });
//            SharedPref().setCheckInStatus(jsonData.ResponseStatus);
          showCommonToast("you have already checked out for the day.");
        }
      } catch (exception) {
        print(exception);
//        showColoredToast("There is some problem");
        if (exception.toString().contains('SocketException')) {
          return 'NetworkError';
        } else {
          return null;
        }
      }
    } else {
//      showColoredToast("There is some problem in Fetching data");
    }
//    }else{
//      showToast("you are already checked out for the day");
//    }
  }

  @override
  void initState() {
    super.initState();
    //_showDialogforlocationPermission();
//    getCurrentLoation();
    _loadNameEmail();
    getCheckInStatus();
    _timerController = StreamController.broadcast();
    _timer = Timer.periodic(
        Duration(seconds: 1), (t) => _timerController.sink.add(t));
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _timerController.close();
  }

  _loadNameEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = (prefs.getString('useremail_id') ?? '');
      _name = (prefs.getString('name') ?? '');
    });
  }

  Future<List> getInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String address = prefs.getString('address');
    String time = prefs.getString('time');
    return [address, time];
  }

  Future setInfo(String address, String time) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('address', address);
    prefs.setString('time', time);
  }

//Widget visible when user is checked IN
  Widget inProgress() {
    return FutureBuilder(
        future: getInfo(),
        builder: (context, snapshot) {
          List info = snapshot.data;
          String address =
              (info == null ? null : info[0]) ?? 'Unable to fetch location';
          String time = (info == null ? null : info[1]) ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Activity In Progress',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.place),
                    Text(address != null
                        ? (address.contains(',')
                            ? address.split(',')[1].length > 2
                                ? address.split(',')[1]
                                : address.split(',')[0]
                            : address)
                        : '')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(address),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Image.asset("Images/checkOut.png")),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Column(
                        children: <Widget>[
                          StreamBuilder(
                              stream: _timerStream,
                              builder: (context, snapshot) {
                                if (time.length > 0) {
                                  DateTime checkInTime = DateTime.parse(time);
                                  _time =
                                      DateTime.now().difference(checkInTime);
                                }
                                return Text(
                                    '${_time.inHours}:${(_time.inMinutes % 60).toString()}:${(_time.inSeconds % 60).toString()}');
                              }),
                          Text('Time Elapsed')
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        });
  }

  Widget dashBoard() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Your Task DashBoard',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, TaskPage.route());
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.calendar_view_day),
                              Text("View \n Tasks", textAlign: TextAlign.center)
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return AddTask();
                            },
                            fullscreenDialog: true));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28.0, vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.add),
                              Text("Add \n Tasks", textAlign: TextAlign.center)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10),
        Image.asset("Images/checkIn.jpg"),
      ],
    );
  }

  Widget checkOutButton() {
    return RaisedButton(
      child: Text('Check Out'),
      onPressed: () async {
        await getGeoLocation(2, context);
      },
    );
  }

  Widget checkInButton() {
    return RaisedButton(
      child: Text('Check In'),
      onPressed: () async {
        await getGeoLocation(1, context);
      },
    );
  }

  // Widget roundButton(String label, VoidCallback onPressed) {
  //   return RaisedButton(
  //     onPressed: onPressed,
  //     child: Column(
  //       children: <Widget>[
  //         Icon(
  //           Icons.playlist_add_check,
  //           color: Colors.white,
  //         ),
  //         Text(
  //           label,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 40.0,
  //           ),
  //         ),
  //       ],
  //     ),
  //     shape: CircleBorder(),
  //     elevation: 10.0,
  //     color: Colors.black,
  //     textColor: Colors.white,
  //     disabledColor: Colors.black45,
  //     disabledTextColor: Colors.black,
  //     splashColor: Colors.white,
  //     padding: const EdgeInsets.all(35.0),
  //   );
  // }

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
                FlatButton(onPressed: () => exit(0), child: Text("Yes")),
              ],
            ));
  }

  startTimer() {}

//  stopTimer() {
//    _timer.cancel();
//  }

  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
        text: "Home Page",
        child: WillPopScope(
            onWillPop: () => willPop(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              _name ?? '',
                              textScaleFactor: 1.5,
                              style: TextStyle(color: Colors.black),
                            ),
                            Text(
                              _email ?? '',
                              style: TextStyle(color: Colors.black),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: checkIn,
                    child: inProgress(),
                    replacement: dashBoard(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(child: checkIn ? checkOutButton() : checkInButton())
//                   roundButton(
//                       "CHECK \n IN",
//                       checkIn
//                           ? null
//                           : () async {
//                               await getGeoLocation(1, context);
// //                    saveCheckInStatus(1);
//                             }),
//                   SizedBox(
//                     height: 10.0,
//                   ),
//                   checkIn
//                       ? Text(
//                           "You are checked In",
//                           style: TextStyle(
//                               fontSize: 20.0,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold),
//                         )
//                       : Text(
//                           "You are checked Out",
//                           style: TextStyle(
//                               fontSize: 20.0,
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold),
//                         ),
//                   SizedBox(
//                     height: 50.0,
//                   ),
//                   roundButton(
//                       "CHECK \n OUT",
//                       !checkIn
//                           ? null
//                           : () async {
//                               await getGeoLocation(2, context);
// //                    saveCheckInStatus(2);
//                             }),
                ],
              ),
            )));
  }

  Future getGeoLocation(int checkFlag, BuildContext context) async {
    var _location = new Location();
    bool permissionStatus = await _location.hasPermission();
    bool servicesStatus = await _location.serviceEnabled();
    if (permissionStatus) {
      if (servicesStatus) {
        return requestLocation(_location, checkFlag);
      } else {
        bool isServiceEnabled = await _location.requestService();
        if (isServiceEnabled) {
          return requestLocation(_location, checkFlag);
        }
      }
    } else {
      bool _permission = await _location.requestPermission();
      if (_permission) {
        if (servicesStatus) {
          return requestLocation(_location, checkFlag);
        } else {
          bool isServiceEnabled = await _location.requestService();
          if (isServiceEnabled) {
            return requestLocation(_location, checkFlag);
          }
        }
      } else {
        showCommonToast("Location permission denied cannot update attendance.");
      }
    }
  }

  Future<String> requestLocation(Location location, int checkFlag) async {
    LocationData position = await location.getLocation();
    if (position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;
      String response;
      try {
        List<Placemark> placeMarkAdd =
            await Geolocator().placemarkFromCoordinates(_latitude, _longitude);
        Placemark placemark = placeMarkAdd[0];
        address =
            "${placemark.name}, ${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
        // final String address = await platform.invokeMethod(
        //     'getAddressFromCordinates', {"lat": _latitude, "long": _longitude});
        response = address;
        if (checkFlag == 1)
          await SharedPref()
              .saveCheckInInfo(response, DateTime.now().toIso8601String());
        else
          await SharedPref().clearInfo();
//        List<Placemark> placeMarkAdd = await Geolocator().placemarkFromCoordinates(_latitude ,_longitude);
//        Placemark placemark = placeMarkAdd[0];
//        address = "${placemark.name}, ${placemark.subThoroughfare}, ${placemark.thoroughfare}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
      } catch (ex) {
        print(ex.toString);
        response = "Not Available.";
        showCommonToast("oops! couldn't get your location");
      }
      await saveCheckInStatus(checkFlag, response);
    }
    return address;
  }

  Future getCheckInStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    String url =
        "https://adevole.com/clients/attendance_app/mobile/get_check_status.php?user_id=$userId&security_key=$tokenId";
    print("Url is $url");
//    if(sharedPreferences.get("status")!= 10){
    final response = await http.put(url);
    if (response.statusCode == 200) {
      print(response.body);
      var jsonData = CheckStatusModel.fromJson(json.decode(response.body));
      if (jsonData.responseStatus == 1) {
        SharedPref().saveCheckInInfo(jsonData.address, jsonData.time);
        setState(() {
          checkIn = true;
        });
      } else if (jsonData.responseStatus == 2) {
        setState(() {
          checkIn = false;
        });
      } else if (jsonData.responseStatus == 3) {
        setState(() {
          checkIn = false;
        });
      }
    }
  }
}
