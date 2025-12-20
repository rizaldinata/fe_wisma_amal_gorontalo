import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeStorage() async {
  final prefs = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(prefs);
  serviceLocator.registerSingleton<SharedPrefsStorage>(
    SharedPrefsStorage(prefs),
  );
}