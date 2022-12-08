import 'dart:convert';

List<TaskListModel> parsenews(String responsebody) {
  final parsed = json.decode(responsebody);
  return (parsed["message"] as List)
      .map<TaskListModel>((json) => TaskListModel.fromJson(json))
      .toList();
}

class TaskListModel {
  int id;
  String name;
  String description;
  int userId;
  int assignId;
  String status;
  String createdDate;
  String updatedDate;
  String flag;
  String dueDate;

  TaskListModel(
      {this.id,
      this.name,
      this.description,
      this.userId,
      this.assignId,
      this.status,
      this.createdDate,
      this.updatedDate,
      this.flag,
      this.dueDate});

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    return TaskListModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        userId: json['user_id'] as int,
        assignId: json['assign_id'] as int,
        status: json['status'] as String,
        createdDate: json['created_date'] as String,
        updatedDate: json['updated_date'] as String,
        flag: json['flag'] as String,
        dueDate: json['dueDate'] as String);
  }
}
