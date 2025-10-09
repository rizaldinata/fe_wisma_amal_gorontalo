import 'package:flutter/material.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:get/get.dart';

import '../../../main.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  // Notifier untuk memberitahu perubahan status login secara realtime untuk GoRouter
  final loginStatusNotifier = ValueNotifier<bool>(false);

  final AuthDatasource auth;

  AuthController({
    required this.auth,
  });

  @override
  void onInit() {
    super.onInit();
    initLoginStatus().then((value) {
      loginStatusNotifier.value = value;
      print('Auth Controller initialized - isLoggedIn: $value');
    });


    // Listen perubahan isLoggedIn dan update loginStatusNotifier
    ever(isLoggedIn, (val) {
      print('AuthController - isLoggedIn changed to: $val');
      loginStatusNotifier.value = val;
    });
  }



  Future<bool> initLoginStatus() async {
    print('Checking initial login status...');
    var status = await auth.isLoggedIn();
    isLoggedIn.value = status;
    print('Initial login status: $status');
    return isLoggedIn.value;
  }

  Future<bool> login({required String username, required String password}) async{
    try {
      print('Starting login process...');
      await auth.login(
      username,
      password,
    );
    print('Login successful, updating state...');
    isLoggedIn.value = true;
    
    // Tampilkan pesan sukses
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Login berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
    
    return true;
    } on AppException catch (e) {
      print('Login failed: ${e.message}');
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(' Error: ${e.message}')),
      );
      return false;
    } catch (e) {
      print('Login failed with unexpected error: $e');
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(' Error: ${e.toString()}')),
      );
      return false;
    }
  }

  // Example methods to update the login state
  Future<void> logout() async {
    try {
      await auth.logout();
      isLoggedIn.value = false;
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      // Even if logout fails, still update local state
      isLoggedIn.value = false;
    }
  }
}
