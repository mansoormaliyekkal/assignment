class AddCommentModel {
  final int responseStatus;
  final String time;

  AddCommentModel({this.responseStatus, this.time});

  factory AddCommentModel.fromJson(Map<String, dynamic> json) {
    return AddCommentModel(
        responseStatus: json['ResponseStatus'] as int,
        time: json['time'] as String);
  }
}
