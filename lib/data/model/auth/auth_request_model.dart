class AuthRequestModel {
  final String email;
  final String? username;
  final String password;
  final String? passwordConfirmation;

  AuthRequestModel({
    required this.email,
    required this.password,
    this.username,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (username != null) 'name': username,
      if (passwordConfirmation != null)
        'password_confirmation': passwordConfirmation,
    };
  }
}
