class AuthRequestModel {
  final String email;
  final String? username;
  final String password;
  final String? passwordConfirmation;
  final String? phoneNumber;

  AuthRequestModel({
    required this.email,
    required this.password,
    this.username,
    this.passwordConfirmation,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      if (username != null) 'name': username,
      if (passwordConfirmation != null)
        'password_confirmation': passwordConfirmation,
      if (phoneNumber != null) 'phone_number': phoneNumber,
    };
  }
}
