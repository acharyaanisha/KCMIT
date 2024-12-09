class StudentView {
  String fullName;
  String email;
  String phoneNumber;
  String dateOfBirth;
  String gender;
  String address;
  String batch;
  String enrollmentDate;
  String? profilePicture;
  String uuid;
  String enrolledProgramName;
  String enrolledSemesterName;

  StudentView({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.batch,
    required this.enrollmentDate,
    this.profilePicture,
    required this.uuid,
    required this.enrolledProgramName,
    required this.enrolledSemesterName
  });

  factory StudentView.fromJson(Map<String, dynamic> json) {
    return StudentView(
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        dateOfBirth: json['dateOfBirth'],
        gender: json['gender'],
        address: json['address'],
        batch: json['batch'],
        enrollmentDate: json['enrollmentDate'],
        profilePicture: json['profilePicture'],
        uuid: json['uuid'],
        enrolledProgramName: json['enrolledProgramName'],
        enrolledSemesterName: json['enrolledSemesterName']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'address': address,
      'batch': batch,
      'enrollmentDate': enrollmentDate,
      'profilePicture': profilePicture,
      'uuid': uuid,
      'enrolledProgramName': enrolledProgramName,
      'enrolledSemesterName': enrolledSemesterName,
    };
  }
}