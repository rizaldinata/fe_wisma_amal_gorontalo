class UserModel {
  int? id;
  String? name;
  String? email;
  String? selectedRoles;
  List<String>? permissions;
  String? createdAt;

  UserModel(
      {this.id,
      this.name,
      this.email,
      this.selectedRoles,
      this.permissions,
      this.createdAt});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    selectedRoles = (json['roles'] as List).isNotEmpty ? json['roles'][0] : null;
    permissions = json['permissions'].cast<String>();
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['roles'] = selectedRoles;
    data['permissions'] = permissions;
    data['created_at'] = createdAt;
    return data;
  }
}
