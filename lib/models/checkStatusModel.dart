class CheckStatusModel {
  final int responseStatus;
  final String message;
  final String address;
  final String time;

  CheckStatusModel({this.responseStatus, this.message,this.address,this.time});

  factory CheckStatusModel.fromJson(Map<String, dynamic> json) {
    return CheckStatusModel(
        responseStatus: json['ResponseStatus'], message: json['Message'],time:json['Time'],address: json['Address'] );
  }
}