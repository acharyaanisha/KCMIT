class Parent {
  String email;
  String password;

  Parent({
    required this.email,
    required this.password
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(email: json['email'],
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