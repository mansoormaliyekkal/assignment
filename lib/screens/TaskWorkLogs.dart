import 'dart:async';
import 'dart:convert';

import 'package:ams/models/AddCommentModel.dart';
import 'package:ams/models/WorkLogsModel.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskWorkLogs extends StatefulWidget {
  final int taskId;

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => TaskWorkLogs(),
    );
  }

  TaskWorkLogs({Key key, this.taskId}) : super(key: key);

  @override
  _WorkLogsState createState() => _WorkLogsState();
}

class _WorkLogsState extends State<TaskWorkLogs> {
  final TextEditingController _hrsController = TextEditingController();
  final TextEditingController _minsController = TextEditingController();
  List<Message> workLogList;
  bool _isLoading = false;

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
    _getWorkLogs(widget.taskId);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
        text: "Task Logs",
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                icon: Icon(
                  Icons.add,
                  // color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildAboutDialog(context),
                  );
                }),
          )
        ],
        child: !internetConn
            ? Center(
                child: noConnection(),
              )
            : _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : workLogList.length == 0
                    ? Center(
                        child: Text(
                          "Task log is empty",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: workLogList != null ? workLogList.length : 0,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  workLogList[index].hours + " hours",
                                ),
                                subtitle: Row(
                                  children: <Widget>[
                                    Text("Date: "),
                                    Text(
                                      workLogList[index].createdDate,
                                      ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                color: Colors.black,
                              )
                            ],
                          );
                        }));
  }

  Widget _buildAboutDialog(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.all(0.0),
      title: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  color: Colors.black,
                ),
                Text(
                  "  Set Hours",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          )),
      /*Row(
        children: <Widget>[
          Icon(Icons.access_time, color: Colors.black,),
          Text("Set Time", style: TextStyle(
            fontSize: 20.0
          ),),
        ],
      ),*/
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Type in time",
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 50.0,
                  margin: EdgeInsets.only(right: 10.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2)
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.black,
                            hintText: "00"),
                        keyboardType: TextInputType.number,
                        controller: _hrsController,
                      ),
                      Text(
                        "HR",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(fontSize: 20.0),
                ),
                Container(
                    width: 50.0,
                    margin: EdgeInsets.only(left: 10.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
//                          validator: (String value) =>
//                          int.parse(value)
//                              > 59 ? 'Invalid minutes'
//                              : null,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2)
                          ],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.black,
                              hintText: "00"),
                          keyboardType: TextInputType.number,
                          controller: _minsController,
                        ),
                        Text(
                          "MIN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                commonButton("Cancel", () {
                  Navigator.pop(context);
                }),
                SizedBox(
                  width: 10.0,
                ),
                commonButton("Add", () {
                  if (_hrsController.text.trim().length == 0 ||
                      _minsController.text.trim().length == 0) {
                    showCommonToast("Fields cannot be empty.");
                  } else {
                    addWorkLog(_hrsController.text, _minsController.text,
                        widget.taskId);
                    Navigator.pop(context);
                  }
                }),
              ],
            )
          ],
        )
      ],
      /*content:  Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Type in time",style: TextStyle(
              fontSize: 20.0
          ),),
          SizedBox(height: 10.0,),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 50.0,
                margin: EdgeInsets.only(right: 10.0),
                child:  Column(
                  children: <Widget>[
                    TextField(
                      decoration:  InputDecoration(
                        border: OutlineInputBorder(),
                        fillColor: Colors.black,
                      ),
                      keyboardType: TextInputType.number,
                      controller: _hrsController,
                    ),
                    Text("HR",style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
              ),
              Text(":", style: TextStyle(
                  fontSize: 20.0
              ),),
              Container(
                  width: 50.0,
                  margin: EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(),
                          fillColor: Colors.black,
                        ),
                        keyboardType: TextInputType.number,
                        controller: _minsController,
                      ),
                      Text("MIN",style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),)
                    ],
                  )
              )
            ],
          )
        ],
      ),*/
      /*actions: <Widget>[
        commonButton("Cancel", (){
          Navigator.pop(context);
        }),
        commonButton("Add", (){
          if (_hrsController.text.trim().length == 0 || _minsController.text.trim().length == 0) {
            showcommonToast("Fields cannot be empty.");
          } else {
            addWorkLog(_hrsController.text,_minsController.text, widget.taskId);
            Navigator.pop(context);
          }
        }),
      ],*/
    );
  }

  addWorkLog(String hrValue, String minValue, int taskId) async {
    var client = http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      String url =
          "http://adevole.com/clients/attendance_app/mobile/add_worklog.php?user_id=$userId&security_key=$tokenId&task_id= $taskId&noh=$hrValue:$minValue";
      final response = await client.put(url);
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonData = AddCommentModel.fromJson(json.decode(response.body));
        String time = jsonData.time;
        Message message = Message();
        message.taskId = 0;
        message.userId = 1;
        message.hours = hrValue + ":" + minValue;
        message.flag = "1";
        message.updatedDate = "123";
        message.id = 0;
        message.createdDate = time;
        _hrsController.text = "";
        _minsController.text = "";

        setState(() {
          workLogList.add(message);
        });
      }
    } catch (exception) {
      print(exception);
    }
  }

  _getWorkLogs(int taskId) async {
    var client = http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      setState(() {
        _isLoading = true;
      });
      String url =
          "http://adevole.com/clients/attendance_app/mobile/list_worklog.php?"
          "user_id=$userId&security_key=$tokenId&task_id=$taskId";
      final response = await client.put(url);
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonData = WorkLogsModel.fromJson(json.decode(response.body));
        setState(() {
          workLogList = jsonData.message;
          _isLoading = false;
        });
      }
    } catch (exception) {
      print(exception);
    }
  }
}
