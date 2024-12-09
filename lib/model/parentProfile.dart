class ParentProfile {
  final String fullName;
  final String email;
  final String phoneNumber;

  ParentProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });


  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  // Method to convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}