class MemberList {
  String name;
  String email;
  String password;
  String mobileNumber;
  String qualification;
  String specialization;
  DateTime hireDate;
  String status;
  String? profilePic;
  String uuid;
  DateTime lastLoginTime;
  DateTime createdAt;
  DateTime updatedAt;

  MemberList({
    required this.name,
    required this.email,
    required this.password,
    required this.mobileNumber,
    required this.qualification,
    required this.specialization,
    required this.hireDate,
    required this.status,
    this.profilePic,
    required this.uuid,
    required this.lastLoginTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemberList.fromJson(Map<String, dynamic> json) {
    return MemberList(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      mobileNumber: json['mobileNumber'],
      qualification: json['qualification'],
      specialization: json['specialization'],
      hireDate: DateTime.parse(json['hire_date']),
      status: json['status'],
      profilePic: json['profile_pic'],
      uuid: json['uuid'],
      lastLoginTime: DateTime.parse(json['lastLoginTime']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'mobileNumber': mobileNumber,
      'qualification': qualification,
      'specialization': specialization,
      'hire_date': hireDate.toIso8601String(),
      'status': status,
      'profile_pic': profilePic,
      'uuid': uuid,
      'lastLoginTime': lastLoginTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
