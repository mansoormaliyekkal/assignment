//List<TaskComments> taskComments(String responsebody){
//  final parsed = json.decode(responsebody);
//  return (parsed["Comments"] as List)
//      .map<TaskComments>((json) => TaskDetailsModel.fromJson(json))
//      .toList();
//}
//
class TaskDetailsModel {
  int responseStatus;
  Message message;

  TaskDetailsModel({this.responseStatus, this.message});

  factory TaskDetailsModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailsModel(
        responseStatus: json['ResponseStatus'],
        message: Message.fromJson(json['message']));
  }
}

class Message {
  int id;
  String name;
  String desc;
  int userId;
  int assignId;
  String status;
  String dueDate;
  String createdDate;
  String updatedDate;
  String flag;
  String path;
  String documentName;
  List<Comments> comments;

  Message(
      {this.id,
      this.name,
      this.desc,
      this.userId,
      this.assignId,
      this.status,
      this.createdDate,
      this.updatedDate,
      this.flag,
      this.path,
      this.documentName,
      this.comments,
      this.dueDate});

  factory Message.fromJson(Map<String, dynamic> parsedJson) {
    //var _pathList = parsedJson['Paths'] as List;
    var list = parsedJson['Comments'] as List;

    //List<Paths> pathList = _pathList.map((i)=> Paths.fromJson(i)).toList();
    List<Comments> commentsList =
        list.map((i) => Comments.fromJson(i)).toList();

    return Message(
      id: parsedJson['id'],
      name: parsedJson['name'],
      desc: parsedJson['description'],
      userId: parsedJson['user_id'],
      assignId: parsedJson['assign_id'],
      status: parsedJson['status'],
      dueDate: parsedJson['dueDate'],
      createdDate: parsedJson['created_date'],
      updatedDate: parsedJson['updated_date'],
      flag: parsedJson['flag'],
      path: parsedJson['Path'],
      documentName: parsedJson['document_name'],
      comments: commentsList,
    );
  }
}
/*
class Paths{
  String path;

  Paths({this.path});

  factory Paths.fromJson(Map<String, dynamic> parsedJson){
    return Paths(
        path:parsedJson['path']
    );
  }

}*/

class Comments {
  String comment;
  String createdDate;

  Comments({this.comment, this.createdDate});

  factory Comments.fromJson(Map<String, dynamic> parsedJson) {
    return Comments(
        comment: parsedJson['Comment'],
        createdDate: parsedJson['created_date']);
  }
}
