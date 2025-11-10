class RegisterRequestModel {
  String name;
  String email;
  String password;
  String passwordConfirmation;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, String?> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
