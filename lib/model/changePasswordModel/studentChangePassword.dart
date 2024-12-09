class StChangePassword {
  String oldPassword;
  String newPassword;
  String confirmPassword;

  StChangePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword
  });

  factory StChangePassword.fromJson(Map<String, dynamic> json) {
    return StChangePassword(
        oldPassword: json['oldPassword'],
        newPassword: json['newPassword'],
        confirmPassword: json['confirmPassword']);
  }

  Map<String, dynamic> toJson() {
    return {
    'oldPassword': oldPassword,
    'newPassword': newPassword,
    'confirmPassword': confirmPassword,
  };
  }
}