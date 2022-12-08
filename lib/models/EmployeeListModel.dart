class EmployeeListModel {
  int responseStatus;
  String message;
  List<Data> employeeList;

  EmployeeListModel({this.responseStatus,this.message,this.employeeList});

  factory EmployeeListModel.fromJson(Map<String,dynamic> parsedJson){
    var list = parsedJson['data'] as List;

    List<Data> empList = list.map((i) => Data.fromJson(i)).toList();

    return EmployeeListModel(
      responseStatus:parsedJson['ResponseStatus'],
      message:parsedJson['Message'],
      employeeList:empList,
    );
  }
}

class Data {
  int id;
  String name;

  Data({this.id,this.name});

  factory Data.fromJson(Map<String,dynamic> parsedJson){
    return Data(
      id:parsedJson['id'],
      name: parsedJson['name'],
    );
  }
}