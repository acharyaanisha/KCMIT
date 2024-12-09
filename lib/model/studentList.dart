class StudentList {
  final String fullName;
  final String? profilePicture;
  final String uuid;
  final String enrolledCourse;

  StudentList({
    required this.fullName,
    this.profilePicture,
    required this.uuid,
    required this.enrolledCourse,
  });


  factory StudentList.fromJson(Map<String, dynamic> json) {
    return StudentList(
      fullName: json['fullName'],
      profilePicture: json['profilePicture'],
      uuid: json['uuid'],
      enrolledCourse: json['enrolledCourse'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'profilePicture': profilePicture,
      'uuid': uuid,
      'enrolledCourse': enrolledCourse,
    };
  }
}
