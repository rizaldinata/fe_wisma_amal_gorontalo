import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsStorage{
  static const _key = 'access_token';
  SharedPrefsStorage(this._prefs);

 final SharedPreferences _prefs;
  
  // Simpan token ke SharedPreferences

  Future<void> saveToken(String token) async {
   await _prefs.setString(_key, token);
  }

  
  String? getToken()  {
    return _prefs.getString(_key);
  }

  
   Future<void> clearToken() async {
    await _prefs.remove(_key);
  }



  // Generic methods for other data types if needed

  Future<void> set(String key, String value) async {
    await _prefs.setString(key, value);
  }

 Future<void> setList(String key, List<String> data) async {
   await _prefs.setStringList(key, data);
  }

  List<String>? getList(String key)  {
    return _prefs.getStringList(key);
  }

  String? get(String key)  {
    return _prefs.getString(key);
  }

  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
