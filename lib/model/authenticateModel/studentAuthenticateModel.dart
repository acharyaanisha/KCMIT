class Student {
  String email;
  String password;

  Student({
    required this.email,
    required this.password
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(email: json['email'],
        password: json['password']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}