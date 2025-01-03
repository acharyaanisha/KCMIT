class ParentChangePassword {
  String oldPassword;
  String newPassword;
  String confirmPassword;

  ParentChangePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword
  });

  factory ParentChangePassword.fromJson(Map<String, dynamic> json) {
    return ParentChangePassword(
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