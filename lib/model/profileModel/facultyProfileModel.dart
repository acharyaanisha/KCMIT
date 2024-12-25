class FacultyProfile {
  final String name;
  final String email;
  final String mobileNumber;
  final String qualification;
  final String specialization;
  final String hireDate;
  final String? profile_pic;
  final int faculty_category_id;

  FacultyProfile({
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.qualification,
    required this.specialization,
    required this.hireDate,
    this.profile_pic,
    required this.faculty_category_id,
  });

  factory FacultyProfile.fromJson(Map<String, dynamic> json) {
    return FacultyProfile(
      name: json['name'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      qualification: json['qualification'],
      specialization: json['specialization'],
      hireDate: json['hire_date'],
      profile_pic: json['profile_pic'],
      faculty_category_id: json['faculty_category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'qualification': qualification,
      'specialization': specialization,
      'hire_date': hireDate,
      'profile_pic': profile_pic,
      'faculty_category_id': faculty_category_id,
    };
  }
}
