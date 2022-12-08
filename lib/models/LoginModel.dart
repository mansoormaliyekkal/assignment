class LoginModel {
  final int responseStatus;
  //final Map<String, dynamic> message;
  final bool success;
  final String token;
  MessageResponseModel messageResponseModel;

  LoginModel(
      {this.responseStatus,
      this.success,
      this.token,
      this.messageResponseModel});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
        responseStatus: json['ResponseStatus'],
        //message: json['message'],
        success: json['success'],
        token: json['token'],
        messageResponseModel: MessageResponseModel.fromJson(json['message']));
  }
}

class MessageResponseModel {
  final int id;
  final int roleId;
  final String emailId;
  final String phoneNo;
  final String empId;
  final int supervisorId;
  final String doj;
  final String forgotPassKey;
  final String createdDate;
  final String updatedDate;
  final String flag;
  final String name;
  final String token;

  MessageResponseModel(
      {this.id,
      this.roleId,
      this.emailId,
      this.phoneNo,
      this.empId,
      this.supervisorId,
      this.doj,
      this.forgotPassKey,
      this.createdDate,
      this.updatedDate,
      this.flag,
      this.name,
      this.token});

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageResponseModel(
        id: json['id'],
        roleId: json['role_id'],
        emailId: json['email_id'],
        phoneNo: json['phone_no'],
        empId: json['emp_id'],
        supervisorId: json['supervisor_id'],
        doj: json['doj'],
        forgotPassKey: json['forgot_pass_key'],
        createdDate: json['created_date'],
        updatedDate: json['updated_date'],
        flag: json['flag'],
        name: json['name'],
        token: json['token']);
  }
}
