class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final List<String>? roles;
  final Set<String>? permissions;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.roles,
    this.permissions,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []).toSet(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
      'permissions': permissions,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
