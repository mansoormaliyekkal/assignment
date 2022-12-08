class WorkLogsModel{
  int responseStatus;
  List<Message> message;

  WorkLogsModel({
    this.responseStatus,this.message
  });

factory WorkLogsModel.fromJson(Map<String,dynamic> parsedJson){
  var list = parsedJson['message'] as List;

  List<Message> logList = list.map((i) => Message.fromJson(i)).toList();

  return WorkLogsModel(
    responseStatus:parsedJson['ResponseStatus'],
    message:logList,
  );
}

}

class Message{
  int id;
  int taskId;
  int userId;
  String hours;
  String createdDate;
  String updatedDate;
  String flag;

  Message({this.id,this.taskId,this.userId,this.createdDate,this.updatedDate,this.flag,this.hours});

  factory Message.fromJson(Map <String,dynamic> parsedJson){
    return Message(
      id: parsedJson['id'],
      taskId: parsedJson['task_id'],
      userId: parsedJson['user_id'],
      createdDate: parsedJson['created_date'],
      updatedDate: parsedJson['updated_date'],
      flag: parsedJson['flag'],
      hours: parsedJson['hours']
    );
  }

}