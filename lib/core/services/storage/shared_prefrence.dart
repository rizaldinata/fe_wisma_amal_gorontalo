import 'dart:core';

import 'package:frontend/core/constant/storage_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStorage {
  static const _key = 'access_token';
  SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  // Simpan token ke SharedPreferences
  Future<void> saveToken(String token) async {
    await _prefs.setString(_key, token);
  }

  String? getToken() {
    return _prefs.getString(_key);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_key);
  }

  // Simpan permissions data
  Future<void> setPermissions(Set<String> permisions) async {
    var list = permisions.toList();
    await _prefs.setStringList(StorageConstant.permissions, list);
  }

  Set<String>? getPermissions() {
    var permissions = _prefs.getStringList(StorageConstant.permissions);
    return permissions!.toSet();
  }

  // Generic methods for other data types if needed

  Future<void> setList(String key, List<String> data) async {
    await _prefs.setStringList(key, data);
  }

  List<String>? getList(String key) {
    return _prefs.getStringList(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? get(String key) {
    return _prefs.getString(key);
  }

  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
