class Faculty {
  String email;
  String password;

  Faculty({
    required this.email,
    required this.password
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(email: json['email'],
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