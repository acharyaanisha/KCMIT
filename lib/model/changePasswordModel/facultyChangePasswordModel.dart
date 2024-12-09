class FacultyChangePassword {
  String oldPassword;
  String newPassword;
  String confirmPassword;

  FacultyChangePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword
  });

  factory FacultyChangePassword.fromJson(Map<String, dynamic> json) {
    return FacultyChangePassword(
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