class PermissionManager {
  final Set<String> _permissions;

  PermissionManager(dynamic rawPermissions)
      : _permissions = _parse(rawPermissions);

  static Set<String> _parse(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  /// cek 1 permission
  bool can(String permission) {
    return _permissions.contains(permission);
  }

  /// salah satu boleh
  bool canAny(Iterable<String> permissions) {
    return permissions.any(_permissions.contains);
  }

  /// semua harus boleh
  bool canAll(Iterable<String> permissions) {
    return permissions.every(_permissions.contains);
  }

  /// debug / logging
  List<String> get all => _permissions.toList();
}
