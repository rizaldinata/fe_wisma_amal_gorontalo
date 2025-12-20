class AuthRequestModel {
  final String email;
  final String? username;
  final String password;

  AuthRequestModel({
    required this.email,
    required this.password,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (username != null) 'username': username,
    };
  }

  
}
