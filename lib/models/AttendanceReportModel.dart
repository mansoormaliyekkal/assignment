class AttendanceReportModel {
  int responseStatus;
  List<Message> message;

  AttendanceReportModel({this.responseStatus, this.message});

  factory AttendanceReportModel.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['Message'] as List;

    List<Message> attendanceList =
        list.map((i) => Message.fromJson(i)).toList();
    return AttendanceReportModel(
        responseStatus: parsedJson['ResponseStatus'], message: attendanceList);
  }
}

class Message {
  String inTime;
  String outTime;
  String hrsWorked;
  String outAddress;
  String inAddress;
  String createdDate;

  Message(
      {this.inTime,
      this.outTime,
      this.hrsWorked,
      this.outAddress,
      this.createdDate,
      this.inAddress});

  factory Message.fromJson(Map<String, dynamic> parsedJson) {
    return Message(
        inTime: parsedJson['in_time'],
        outTime: parsedJson['out_time'],
        hrsWorked: parsedJson['hours_worked'],
        inAddress: parsedJson['IN_address'],
        outAddress: parsedJson['OUT_address'],
        createdDate: parsedJson['created_date']);
  }
}
