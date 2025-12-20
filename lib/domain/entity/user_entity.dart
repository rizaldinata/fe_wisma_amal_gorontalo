class UserEntity {
  int? id;
  String name;
  String email;
  List<String> roles;
  List<String>? permissions;

  UserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.permissions,
  });
}
