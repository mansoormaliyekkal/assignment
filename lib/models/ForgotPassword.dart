class ForgotPassModel {
  final int responseStatus;
  final String message;
  final String errorMessage;

  ForgotPassModel({this.responseStatus, this.message, this.errorMessage});

  factory ForgotPassModel.fromJson(Map<String, dynamic> json) {
    return ForgotPassModel(
        responseStatus: json['ResponseStatus'],
        message: json['message'],
        errorMessage: json['ErrorMessage']);
  }
}
