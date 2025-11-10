class AuthErrorModel {
  final Map<String, List<String>> errors;

  AuthErrorModel({required this.errors});

  factory AuthErrorModel.fromJson(Map<String, dynamic> json) {
    final errors = json.map((key, value) {
      return MapEntry(key, List<String>.from(value));
    });
    return AuthErrorModel(errors: errors);
  }

  String? firstError(String field) {
    final fieldErrors = errors[field];
    return fieldErrors != null && fieldErrors.isNotEmpty ? fieldErrors.first : null;
  }
}
