import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ams/models/TaskDetailsModel.dart';
import 'package:ams/screens/AllCommentPage.dart';
import 'package:ams/screens/TaskWorkLogs.dart';
import 'package:ams/screens/widgets/commonTextField.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetails extends StatefulWidget {
  final int taskId;
  TaskDetails({Key key, this.taskId}) : super(key: key);

  @override
  _TaskDetailsState createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  // List<dynamic> _filePath;
  String taskStatus;
  var comments;
  String _fileName = '...';
  String filePath;
  String _fileName1;
  String fileName;
  String documentName;
  var tokenId;
  var userId;
  bool loading = false;
  String documentUrl;

  Dio dio = Dio();

  bool uploading = false;
  var progressString = "";
  var savePath;

  bool internetConn = true;
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;

  String _savedStatus;

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

  getSFData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      tokenId = sharedPreferences.getString('userToken' ?? false);
      userId = sharedPreferences.getInt('userId' ?? false);
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    getSFData();
    _getTaskDetails(widget.taskId);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  /*Widget pathList(){
    return ListView.builder(
      itemCount: uploadedFile.length,
        itemBuilder: (_, index){
        print("Path is ${uploadedFile[index].path}");
      return Text(uploadedFile[index].path);
    });
}*/

  Future<void> downloadFile() async {
    try {
      savePath = await getExternalStorageDirectory();
      setState(() {
        uploading = true;
      });
      await dio.download(
        documentUrl,
        "${savePath.path}/testdocument",
        onReceiveProgress: (int sent, int total) {
          print("Saved path is ${savePath.path}/$documentName");
          setState(() {
            progressString = ((sent / total) * 100).toStringAsFixed(0) + "%";
          });
          print("$progressString");
        },
      );
      setState(() {
        uploading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  launchURL() async {
    print("URL IS $documentUrl");
    if (await canLaunch(documentUrl)) {
      await launch(documentUrl);
    } else {
      throw 'Could not launch $documentUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
      text: "Task Details",
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: (_savedStatus == taskStatus && _fileName1 == null)
                ? null
                : () {
                    saveTaskStatus(widget.taskId)
                        .whenComplete(() => uploadFile()
                          ..then((val) {
                            Navigator.pop(context);
                          }));
                  },
            child: Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: !internetConn
              ? Center(
                  child: noConnection(),
                )
              : loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Card(
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CommonTextField(
                                    controller: _projectNameController,
                                    label: "Task Name",
                                    labelColor: Theme.of(context).primaryColor,
                                    validator: null,
                                    disable: false,
                                    outlineBorder: false,
                                  ),
                                  CommonTextField(
                                    controller: _subjectController,
                                    label: "Description :-",
                                    labelColor: Theme.of(context).primaryColor,
                                    outlineBorder: false,
                                    validator: null,
                                    disable: false,
                                  ),
                                  CommonTextField(
                                    controller: _dueDateController,
                                    label: "Due Date",
                                    labelColor: Theme.of(context).primaryColor,
                                    validator: null,
                                    outlineBorder: false,
                                    disable: false,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Uploaded file is: ",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  Flexible(
                                    child: InkWell(
                                      child: Text(
                                        documentUrl != null &&
                                                documentUrl.isNotEmpty
                                            ? documentName
                                            : "Empty",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            // color:
                                            //     Theme.of(context).accentColor,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                      onTap: () async {
                                        //downloadFile();
                                        if (documentUrl != null &&
                                            documentUrl.isNotEmpty) {
                                          await launchURL();
                                        } else {
                                          showCommonToast(
                                              "No Document is uploaded");
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Card(
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  ElevatedButton.icon(
                                      onPressed: () async =>
                                          await getFilePath(),
                                      style: ElevatedButton.styleFrom(
                                        shape: StadiumBorder(),
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        //size: 40.0,
                                      ),
                                      label: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "Add Document",
                                          style: TextStyle(
                                              //fontSize: 20.0,
                                              color: Colors.white),
                                        ),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _fileName.length <= 3
                                        ? Text('No file selected.')
                                        : Text(
                                            'File Name: ' + _fileName,
                                            textAlign: TextAlign.start,
                                          ),
                                  ),
                                  uploading
                                      ? Container(
                                          width: 200,
                                          height: 120,
                                          child: Card(
                                            color: Colors.black,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  height: 20.0,
                                                ),
                                                Text(
                                                  "Uploading file: $progressString",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          width: 10.0,
                                        ) /*ElevatedButton.icon(
                            disabledColor: Colors.grey,
                            onPressed: () => UploadFile(),
                            shape: StadiumBorder(),
                            color: Colors.blue,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              //size: 40.0,
                            ),
                            label: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "upload file",
                                style: TextStyle(
                                  //fontSize: 20.0,
                                    color: Colors.white),
                              ),
                            ))*/
                                  ,
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          "Status: ",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: DropdownButtonHideUnderline(
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
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: DropdownButton<String>(
                                                hint: Text(" Select Status"),
                                                items: <String>[
                                                  'Not Started',
                                                  'In Progress',
                                                  'Canceled',
                                                  'Completed',
                                                  'On Hold'
                                                ].map((String value) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: value != null
                                                        ? value
                                                        : "unknown",
                                                    child: new Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (String newVal) {
                                                  setState(() {
                                                    this.taskStatus = newVal;
                                                  });
                                                },
                                                value: taskStatus,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            //crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(right: 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        //topRight: Radius.circular(25.0),
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AllComment(
                                                  comments: comments,
                                                  taskId: widget.taskId,
                                                )));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        "View Comment ",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.comment,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 1.0,
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.only(left: 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        //topLeft: Radius.circular(25.0),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskWorkLogs(
                                                taskId: widget.taskId)));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Icon(
                                        Icons.description,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " View Worklog",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          /*Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: commonButton("Save", () {
                      saveTaskStatus(widget.taskId);
                      UploadFile()..then((val){
                        Navigator.pop(context);
                      });
                    }))*/
                        ],
                      ),
                    )),
    );
  }

  Future<void> getFilePath() async {
    try {
      final file = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      filePath = file.files.first.path;
      if (filePath == '') {
        return;
      }
      print("File path: " + filePath);
      //setState((){this._filePath = filePath;});
      setState(() {
        _fileName = filePath != null ? filePath.split('/').last : '...';
        _fileName1 = _fileName != null ? filePath : '...';
      });
    } catch (e) {
      print("Error while picking the file: " + e.toString());
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
//  initPlatformState() async {
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      _filePath = await DocumentsPicker.pickDocuments;
//    } on PlatformException {}
//
//    if (!mounted) return;
//
//    setState(() {
//      _fileName = _filePath.toString();
//      _fileName1 = _fileName != null ? _fileName.substring(1, _fileName.length - 1) : '...';
//      fileName = _fileName1 != null ? _fileName1.split('/').last : '...';
//      print("File name without slash is $fileName");
//      print("File path is $_fileName1");
//    });
//  }

  Future<void> uploadFile() async {
    Response response;
    if (_fileName1 != null) {
      try {
        FormData formData = new FormData.fromMap({
          "user_id": userId,
          "security_key": tokenId,
          "task_id": widget.taskId,
          "document": MultipartFile.fromFile(_fileName1, filename: _fileName),
        });
        response = await dio.post(
          "http://adevole.com/clients/attendance_app/mobile/upload_document.php",
          data: formData,
          onSendProgress: (int sent, int total) {
            setState(() {
              uploading = true;
              progressString = ((sent / total) * 100).toStringAsFixed(0) + "%";
            });
            print("$progressString");
          },
        );
        showCommonToast("Document uploaded successfully");
        print("Form data is $formData");
        print("Response data is ${response.data}");
      } catch (e) {
        print(e);
        showCommonToast("There is some problem in uploading document");
      }
      setState(() {
        uploading = false;
        progressString = "Completed";
      });
      print("Uploading Completed");
    }
  }

  Future _getTaskDetails(int taskId) async {
    var client = http.Client();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      setState(() {
        loading = true;
      });
      String url =
          "http://adevole.com/clients/attendance_app/mobile/taskslist_detail.php?"
          "user_id=$userId&security_key=$tokenId&task_id=$taskId";
      final response = await client.put(Uri.parse(url));
      print("Task Response body: ${response.body}");
      print("Task details URL is $url");
      if (response.statusCode == 200) {
        var jsonData = TaskDetailsModel.fromJson(json.decode(response.body));
        comments = jsonData.message.comments;
        print("response is succesfull");
        setState(() {
          _savedStatus = jsonData.message.status;
          taskStatus = _savedStatus;
          _projectNameController.text = jsonData.message.name;
          _subjectController.text = jsonData.message.desc;
          _dueDateController.text = jsonData.message.dueDate;
          documentUrl = jsonData.message.path;
          documentName = jsonData.message.documentName;
        });
        print("File path is $documentUrl");
      }
      loading = false;
    } catch (exception) {
      print("Task details exception is $exception");
      showCommonToast("Task details exception is $exception");
    }
  }

  Future<void> saveTaskStatus(int taskId) async {
    if (_savedStatus != taskStatus) {
      var client = new http.Client();
      try {
        String url =
            "http://adevole.com/clients/attendance_app/mobile/save_task_status.php?"
            "user_id=$userId&security_key=$tokenId&task_id=$taskId&taskstatus=$taskStatus";
        final response = await client.put(Uri.parse(url));
        print("Task Response body: ${response.body}");
        if (response.statusCode == 200) {
          showCommonToast("status changed successfully.");
//        var jsonData = TaskDetailsModel.fromJson(json.decode(response.body));
//        comments = jsonData.message.comments;
//        print("response is succesfull");
//        setState(() {
//          taskStatus = jsonData.message.status;
//          _projectNameController.text = jsonData.message.name;
//          _subjectController.text = jsonData.message.desc;
//          _dueDateController.text = jsonData.message.dueDate;
//        });
        }
      } catch (exception) {
        print(exception);
      }
    }
  }
}
