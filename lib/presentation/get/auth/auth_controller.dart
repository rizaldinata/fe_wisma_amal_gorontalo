import 'package:flutter/material.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/model/auth/login_request.dart';
import 'package:frontend/data/model/auth/register_request.dart';
import 'package:frontend/data/model/auth/user_model.dart';
import 'package:get/get.dart';

import '../../../main.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  final loginStatusNotifier = ValueNotifier<bool>(false);

  var userInfo = UserModel().obs;

  var _obscureText = true.obs;

  final AuthDatasource auth;
  final SharedPrefsStorage storage;

  AuthController({required this.auth, required this.storage});

  @override
  void onInit() {
    super.onInit();
    initLoginStatus().then((value) {
      loginStatusNotifier.value = value;
    });
    // Listen perubahan isLoggedIn dan update loginStatusNotifier
    ever(isLoggedIn, (val) {
      loginStatusNotifier.value = val;
    });
  }

  get obscureText => _obscureText.value;

  void toggleObscureText() {
    _obscureText.value = !_obscureText.value;
  }

  void getUserInfo() {
    var email = storage.get(StorageConstant.email);
    var username = storage.get(StorageConstant.userName);
    var userId = storage.get(StorageConstant.userId);
    var role = storage.getList(StorageConstant.roleActive);
    var permissions = storage.getPermissions();

    // Do something with the user info
    userInfo.value = UserModel(
      email: email ?? '',
      name: username ?? '',
      roles: role ?? [],
      id: (userId != null) ? int.parse(userId) : null,
      permissions: permissions ?? {},
    );
  }

  Future<bool> initLoginStatus() async {
    var status = await auth.isLoggedIn();
    isLoggedIn.value = status;
    return isLoggedIn.value;
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      var result = await auth.login(
        LoginRequestModel(email: email, password: password),
      );
      if (result == null) return false;
      isLoggedIn.value = true;
      userInfo.value = result;

      // Tampilkan pesan sukses
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } on AppException catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(' Error: ${e.message}')),
      );
      return false;
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(' Error: ${e.toString()}')),
      );
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      var result = await auth.register(
        RegisterRequestModel(
          name: username,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirm,
        ),
      );
      if (result == null) return false;
      isLoggedIn.value = true;
      userInfo.value = result;

      // Tampilkan pesan sukses
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Register berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } on AppException catch (e) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(' Error: ${e.message}')),
      );
      return false;
    } catch (e) {
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
    } catch (e) {
      isLoggedIn.value = false;
    }
  }
}
