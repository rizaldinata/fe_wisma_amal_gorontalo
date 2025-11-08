import 'package:frontend/data/model/auth/user_model.dart';

class AuthResponse {
  final String token;
  final UserModel? user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: (json['user'] != null) ? UserModel.fromJson(json['user']) : null,
    );
  }

  //Map<String, dynamic> toJson() {
  //  return {'token': token, 'user': user.toJson()};
  // }
}
