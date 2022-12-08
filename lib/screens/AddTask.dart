import 'dart:convert';

import 'package:ams/models/EmployeeListModel.dart';
import 'package:ams/screens/TaskPage.dart';
import 'package:ams/screens/widgets/commonTextField.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  _AddTaskState();

//  List<Map> _myJson = [{"id":0,"name":"<New>"},{"id":1,"name":"Test Practice"}];

//  TextEditingController  _projectNameController = new  TextEditingController();
  TextEditingController controller = new TextEditingController();

  List<Data> empList;
  GlobalKey<AutoCompleteTextFieldState<Data>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;
  String status;
  String userName;

  final TextEditingController _assignedToController = TextEditingController();
  DateTime _date = new DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  String _fileName = '...';
  List<dynamic> _filePath;
  bool _loadProjectName = false;
  String _mySelection;
  final TextEditingController _taskDescController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
//    _getEmployeeNames();
    _getProjectsName();
    // if (_dateController.text.length == 0) _dateController.text = 'Select Date';
    getUserName();
  }

  Future<Null> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateController.text.length == 0
            ? DateTime.now()
            : DateTime.parse(_dateController.text),
        firstDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        lastDate: new DateTime(2030));
    Duration diff = (picked != null)
        ? picked.difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        : Duration(days: 0);
    if (picked != null && picked != _date && diff.inDays >= 0) {
      var dateTime = picked.toString();
      String date = dateTime.split(" ").first;
      print('Date Selected: $date');
      _dateController.text = date;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Map temp = await FilePicker.getMultiFilePath();
      _filePath = temp.values;
    } on PlatformException {}

    if (!mounted) return;

    setState(() {
      _fileName = _filePath.toString();
    });
  }

  Future<void> getUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('name' ?? false);
    setState(() {
      _assignedToController.text = userName;
    });
  }

  void _getProjectsName() async {
    var client = new http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      setState(() {
        _loadProjectName = true;
      });
      String url =
          "http://adevole.com/clients/attendance_app/mobile/project_names.php?user_id=$userId&security_key=$tokenId";
      final response = await client.put(url);
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonData = EmployeeListModel.fromJson(json.decode(response.body));
        setState(() {
          this.empList = jsonData.employeeList;
        });
        print('names: $jsonData');
        setState(() {
          _loadProjectName = false;
        });
      }
    } catch (exception) {
      print(exception);
    }
  }

  Future addTask(String projectid, String taskName, String taskDesc,
      String dueDate, String status, int flag) async {
    var client = new http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      String url =
          "http://adevole.com/clients/attendance_app/mobile/addtask.php?user_id=$userId&security_key=$tokenId&assign_id=$userId&status=$status&flag=$flag&title=$taskName&description=$taskDesc&project_id=$projectid&due_date=$dueDate";
      print(url);
      final response = await client.put(url);
      if (response.statusCode == 200) {
        showCommonToast("Task added successfully");
        Navigator.pushReplacement(context, TaskPage.route());
//        var jsonData = EmployeeListModel.fromJson(json.decode(response.body));
//        print(jsonData);
      }
    } catch (exception) {
      print(exception);
    }
  }

//  void _getProjectNames() async{
//    var client = new http.Client();
//
//    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//    var tokenId = sharedPreferences.getString('userToken' ?? false);
//    var userId = sharedPreferences.getInt('userId' ?? false);
//    try{
//      String url =
//          "http://adevole.com/clients/attendance_app/mobile/employeeNames.php?user_id=$userId&security_key=$tokenId";
//      final response = await client.put(url);
//      print("Task Response body: ${response.body}");
//      if(response.statusCode == 200){
//
//        var jsonData = EmployeeListModel.fromJson(json.decode(response.body));
//        print(jsonData);
//
////        comments = jsonData.message.comments;
////        print("response is succesfull");
////        setState(() {
////          taskStatus = jsonData.message.status;
////          _projectNameController.text = jsonData.message.name;
////          _subjectController.text = jsonData.message.desc;
////          _dueDateController.text = jsonData.message.dueDate;
////        });
//
//      }
//    }
//    catch(exception){
//      print(exception);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text("Add New Task",
            style: TextStyle(color: Theme.of(context).primaryColor)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 10.0,
                margin: EdgeInsets.only(top: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Task Details',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(height: 20),
                      _loadProjectName
                          ? CircularProgressIndicator()
                          : DropdownButtonHideUnderline(
                              child: Container(
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1.0,
                                        style: BorderStyle.solid),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: DropdownButton<String>(
                                    hint: Text("Select Project"),
                                    value: _mySelection,
                                    onChanged: (String newValue) {
                                      setState(() {
                                        _mySelection = newValue;
                                      });
                                      print(_mySelection);
                                    },
                                    items: empList == null
                                        ? null
                                        : empList.map((map) {
                                            return new DropdownMenuItem<String>(
                                              value: map.id.toString() != null
                                                  ? map.id.toString()
                                                  : "",
                                              child: new Text(
                                                map.name != null
                                                    ? map.name
                                                    : "",
                                              ),
                                            );
                                          }).toList(),
//                          items: <String>[
//                            'Not Started',
//                            'In Progress',
//                            'Canceled',
//                            'Completed',
//                            'On Hold'
//                          ].map((String value) {
//                            return new DropdownMenuItem<String>(
//                              value: value,
//                              child: new Text(value),
//                            );
//                          }).toList(),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 20),
//                      Align(
//                          alignment: Alignment.centerLeft,
//                          child: Text('Task name')),
                      CommonTextField(
                        label: "Task name",
                        controller: _taskNameController,
                        validator: null,
                      ),
                      SizedBox(height: 20),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Descriptions:-')),
                      SizedBox(height: 5),
                      CommonTextField(
                        outlineBorder: true,
                        label: null,
                        hint: "Task Description",
                        controller: _taskDescController,
                        validator: null,
                        maxLines: 4,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
//                          Expanded(
//                            flex: 5,
//                            child: Text(
//                              "Priority: ",
//                              style: TextStyle(
//                                fontSize: 20.0,
//                              ),
//                            ),
//                          ),
//                          Expanded(
//                            flex: 5,
//                            child: DropdownButtonHideUnderline(
//                              child: DropdownButton<String>(
//                                hint: Text("Select Priority"),
//                                items: <String>['None', 'Low', 'Medium', 'High'].map((String value) {
//                                  return new DropdownMenuItem<String>(
//                                    value: value,
//                                    child: new Text(value),
//                                  );
//                                }).toList(),
//                                onChanged: (_) {},
//                              ),
//                            ),
//                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                selectDate(context);
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: IgnorePointer(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Due Date"),
                                      CommonTextField(
                                        outlineBorder: false,
                                        prefixIcon: Image.asset(
                                            "Images/icon/AmsIcon3.png",
                                            height: 24),
                                        label: null,
                                        hint: 'Select Date',
                                        disable: false,
                                        controller: _dateController,
                                        validator: null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Status: "),
                                DropdownButtonHideUnderline(
                                  child: Container(
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        hint: Text("Select Status"),
                                        items: <String>[
                                          'Not Started',
                                          'In Progress',
                                          'Canceled',
                                          'Completed',
                                          'On Hold'
                                        ].map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newVal) {
                                          setState(() {
                                            this.status = newVal;
                                          });
                                        },
                                        value: status,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
//                          Expanded(
//                            flex: 4,
//                            child: RaisedButton(
//                              onPressed: () {
//                                selectDate(context);
//                              },
//                              color: Colors.black,
//                              child: Row(
//                                children: <Widget>[
//                                  Icon(
//                                    Icons.calendar_today,
//                                    color: Colors.white,
//                                  ),
//                                  Text(" Select Date"),
//                                ],
//                              ),
//                              textColor: Colors.white,
//                            ),
//                          ),
                        ],
                      ),
                      SizedBox(height: 20),
//                      CommonTextField(
//                        label: "",
//                        disable: false,
//                        controller: _assignedToController,
//                        validator: null,
//                      ),
//                      searchTextField = AutoCompleteTextField<Data>(
//                        style:
//                            new TextStyle(color: Colors.black, fontSize: 16.0),
//                        decoration: new InputDecoration(
//                            suffixIcon: Container(
//                              width: 85.0,
//                              height: 60.0,
//                            ),
//                            contentPadding:
//                                EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
//                            filled: true,
//                            hintText: 'Search Project',
//                            hintStyle: TextStyle(color: Colors.black)),
//
//                        itemSubmitted: (item) {
//                          setState(() => searchTextField
//                              .textField.controller.text = item.name);
//                        },
//                        clearOnSubmit: false,
//                        key: key,
//                        suggestions: empList,
//                        itemBuilder: (context, item) {
//                          return Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text(
//                                item.name,
//                                style: TextStyle(fontSize: 16.0),
//                              ),
//                            ],
//                          );
//                        },
//                        itemSorter: (a, b) {
//                          return a.name.compareTo(b.name);
//                        },
//                        itemFilter: (item, query) {
//                          return item.name
//                              .toLowerCase()
//                              .startsWith(query.toLowerCase());
//                        },
////                        (
////                        label: "Project name",
////                        controller: _projectNameController,
////                        validator: (val) {},
////                      ),
//                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8)),
                    onPressed: () {
                      if (_mySelection == null ||
                          _taskNameController.toString().trim().length == 0 ||
                          _taskDescController.text.trim().length == 0 ||
                          _dateController.text.trim().length == 0 ||
                          status == null) {
                        showCommonToast("Cannot Leave fields empty");
                      } else {
                        addTask(
                            _mySelection,
                            _taskNameController.text,
                            _taskDescController.text,
                            _dateController.text,
                            status,
                            1);
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8)),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )
//              Card(
//                elevation: 5.0,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.stretch,
//                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.fromLTRB(10.0, 0.0,10.0,0.0),
//                        child: RaisedButton.icon(
//                            onPressed: () => initPlatformState(),
//                            shape: StadiumBorder(),
//                            color: Colors.green,
//                            icon: Icon(
//                              Icons.add,
//                              color: Colors.white,
//                              //size: 40.0,
//                            ),
//                            label: Padding(
//                              padding: const EdgeInsets.all(12.0),
//                              child: Text(
//                                "Add Document",
//                                style: TextStyle(
//                                    //fontSize: 20.0,
//                                    color: Colors.white),
//                              ),
//                            )),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: _filePath == null ? Text('No file selected.', textAlign: TextAlign.center,) : Text('File Name: ' + _fileName, textAlign: TextAlign.center,),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//              Card(
//                elevation: 5.0,
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: Container(
//                    decoration: BoxDecoration(
//                        border: Border.all(color: Colors.black, style: BorderStyle.solid, width: 2.0)),
//                    child: Padding(
//                      padding: const EdgeInsets.all(2.0),
//                      child: TextFormField(
//                        maxLines: 6,
//                        controller:_commentsController,
//                        style: TextStyle(fontSize: 20.0, color: Colors.black),
//                        decoration: InputDecoration(
//                          border: InputBorder.none, //OutlineInputBorder(),
//                          hintText: "Write a comment...",
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              ),
            ],
          ),
        ),
      ),
    );
  }
}
