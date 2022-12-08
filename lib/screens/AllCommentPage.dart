import 'dart:convert';

import 'package:ams/models/AddCommentModel.dart';
import 'package:ams/models/TaskDetailsModel.dart';
import 'package:ams/screens/widgets/commonbodyStrecture.dart';
import 'package:ams/screens/widgets/commonwidgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AllComment extends StatefulWidget {
  final List<Comments> comments;
  final int taskId;

  AllComment({Key key, this.comments, this.taskId}) : super(key: key);

  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => AllComment(),
    );
  }

  @override
  _AllCommentState createState() => _AllCommentState();
}

class _AllCommentState extends State<AllComment> {
  final TextEditingController _commentsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CommonBodyStructure(
      text: "All Comment",
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 9,
              child: ListView.builder(
                  itemCount: widget.comments.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(widget.comments[index].comment),
                          subtitle: Row(
                            children: <Widget>[
                              Text("Date: "),
                              Text(
                                widget.comments[index].createdDate,
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
                    /*Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:Column(crossAxisAlignment: CrossAxisAlignment.start,children: <Widget>[
                        Text(widget.comments[index].comment, style: TextStyle(
                          fontSize: 20.0,
                        ),),
                        Text(widget.comments[index].createdDate, style: TextStyle(
                          fontSize: 18.0,
                        ),)

                      ],),
                    ),
                  );*/
                  })),
          SizedBox(
            height: 5.0,
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    style: TextStyle(fontSize: 20.0, color: Colors.black),
                    controller: _commentsController,
                    decoration: InputDecoration(
                      border: InputBorder.none, //OutlineInputBorder(),
                      hintText: "Write a comment...",
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (_commentsController.text.trim().length == 0) {
                            showCommonToast("comment cannot be empty.");
                          } else {
                            postComment(
                                widget.taskId, _commentsController.text);
                          }
                        })),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  postComment(int taskId, String newComment) async {
    var client = new http.Client();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tokenId = sharedPreferences.getString('userToken' ?? false);
    var userId = sharedPreferences.getInt('userId' ?? false);
    try {
      String url =
          "http://adevole.com/clients/attendance_app/mobile/addcomments.php?user_id=$userId&security_key=$tokenId&task_id=$taskId&comment=$newComment";
      final response = await client.put(url);
      print("Task Response body: ${response.body}");
      if (response.statusCode == 200) {
        var jsonData = AddCommentModel.fromJson(json.decode(response.body));
        String time = jsonData.time;
        Comments comment = Comments();
        comment.comment = newComment;
        comment.createdDate = time;
        _commentsController.text = "";
        setState(() {
          widget.comments.add(comment);
        });
      }
    } catch (exception) {
      print(exception);
    }
  }
}
