class Permissions {
  final Set<String> _values;

  const Permissions(this._values);

  bool can(String permission) {
    return _values.contains(permission);
  }

  bool any(Iterable<String> permissions) {
    return permissions.any(_values.contains);
  }

  bool all(Iterable<String> permissions) {
    return permissions.every(_values.contains);
  }

  Set<String> get raw => _values;
}
