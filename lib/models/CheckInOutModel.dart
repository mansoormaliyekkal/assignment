class CheckInOutModel {
  final int responseStatus;
  final String message;

  CheckInOutModel({this.responseStatus, this.message});

  factory CheckInOutModel.fromJson(Map<String, dynamic> json) {
    return CheckInOutModel(
        responseStatus: json['ResponseStatus'], message: json['Message']);
  }
}
