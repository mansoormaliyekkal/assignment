import 'dart:async';
import 'dart:ui';

import 'package:ams/models/TaskListModel.dart';
import 'package:ams/screens/AddTask.dart';
import 'package:ams/screens/TaskDetails.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class TaskPage extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => TaskPage(),
    );
  }

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  final List<TaskListModel> news = [];
  String _selectedTaskType = '';
  bool internetConn = true;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  Future fetchNews;

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
    _selectedTaskType = '';
    // if (internetConn) fetchNews = _fetchNews();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Widget taskListsMethod() {
    return FutureBuilder<List<TaskListModel>>(
      future: fetchNews, // a Future<String> or null
      builder: (context, snapshot) {
        List<TaskListModel> allTasks = snapshot.data;
        List<TaskListModel> filteredTasks = [];
        if (snapshot.hasData) {
          if (_selectedTaskType.length != 0) {
            for (int i = 0; i < allTasks.length; i++) {
              if (allTasks[i].status == _selectedTaskType)
                filteredTasks.add(allTasks[i]);
            }
          } else {
            filteredTasks = List.from(allTasks);
          }

          return !internetConn
              ? Center(
                  child: noConnection(),
                )
              : NewsList(taskList: filteredTasks, onTap: _onTap);
        }
        return !internetConn
            ? Center(
                child: noConnection(),
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Function _onTap(int id) {
    Future.delayed(Duration(seconds: 2), () => fetchNews = null);
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => TaskDetails(taskId: id)));
  }

  Future<List<TaskListModel>> _fetchNews() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var client = http.Client();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    print("Data Stored in SF $tokenId \n $userId ");
    String url =
        "http://adevole.com/clients/attendance_app/mobile/taskslist.php?user_id=$userId&security_key=$tokenId";
    print("Url is $url");

    try {
      final response = await client.put(url);
      print("Task Response status: ${response.statusCode}");
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        return compute(parsenews, response.body);
      } else {
        showCommonToast("There is some problem in Fetching data");
      }
    } catch (e) {
      print('Error occured:${e.toString()}');
    }
  }

  void onSelected(String value) {
    Navigator.pop(context);
    setState(() {
      _selectedTaskType = value;
    });
  }

  //Show Filter Dialog
  showFilterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            titlePadding: EdgeInsets.all(0.0),
            title: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Filter Task",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  ),
                )),
            children: <Widget>[
              Divider(
                height: 5,
                color: Colors.black,
              ),
              Column(
                children: <Widget>[
                  RadioListTile(
                    value: "Not Started",
                    groupValue: _selectedTaskType,
                    onChanged: (var value) => onSelected(value),
                    title: Text("Not Started"),
                  ),
                  RadioListTile(
                    value: "In Progress",
                    groupValue: _selectedTaskType,
                    onChanged: (var value) => onSelected(value),
                    title: Text("In Progress"),
                  ),
                  RadioListTile(
                    value: "Canceled",
                    groupValue: _selectedTaskType,
                    onChanged: (var value) => onSelected(value),
                    title: Text("Canceled"),
                  ),
                  RadioListTile(
                    value: "Completed",
                    groupValue: _selectedTaskType,
                    onChanged: (var value) => onSelected(value),
                    title: Text("Completed"),
                  ),
                  RadioListTile(
                    value: "On Hold",
                    groupValue: _selectedTaskType,
                    onChanged: (var value) => onSelected(value),
                    title: Text("On Hold"),
                  ),
                ],
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (fetchNews == null) if (internetConn) fetchNews = _fetchNews();
    return CommonBodyStructure(
        text: "Task",
        actions: <Widget>[
          IconButton(
              icon: Image.asset(
                "Images/icon/filter.png",
                height: 24,
              ),
              onPressed: () => showFilterDialog())
        ],
        child: Padding(
            padding: const EdgeInsets.all(15.0), child: taskListsMethod()),
        fab: FloatingActionButton(
          backgroundColor: Colors.indigoAccent,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<Null>(
                builder: (BuildContext context) {
                  Future.delayed(Duration(seconds: 2), () => fetchNews == null);
                  return AddTask();
                },
                fullscreenDialog: true));
          },
        ));
  }
}

class NewsList extends StatelessWidget {
  final List<TaskListModel> taskList;
  final Function(int) onTap;

  NewsList({Key key, this.taskList, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          var format = intl.DateFormat("d MMMM y");
          String _date = format.format(DateTime.parse(taskList[index].dueDate));
          return Card(
            elevation: 5.0,
            child: ListTile(
              title: Text(
                taskList[index].name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    taskList[index].description,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "Status: ",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        taskList[index].status,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Text(
                        "Due Date: ",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        _date,
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => onTap(taskList[index].id),
            ),
          );
        });
  }
}
