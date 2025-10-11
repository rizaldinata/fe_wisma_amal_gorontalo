import 'package:flutter/material.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/data/model/user_model.dart';
import 'package:get/get.dart';

import '../../../main.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  // Notifier untuk memberitahu perubahan status login secara realtime untuk GoRouter
  final loginStatusNotifier = ValueNotifier<bool>(false);

  var userInfo = UserModel().obs;

  final AuthDatasource auth;
  final SharedPrefsStorage storage;

  AuthController({
    required this.auth,
    required this.storage,
  });

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



  Future<bool> initLoginStatus() async {
    var status = await auth.isLoggedIn();
    isLoggedIn.value = status;
    return isLoggedIn.value;
  }



  Future<bool> login({required String username, required String password}) async{
    try {
     var result = await auth.login(
      username,
      password,
    );
    isLoggedIn.value = true;
    
    userInfo.value = result;

    // Tampilkan pesan sukses
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('Login berhasil!'),
        backgroundColor: Colors.green,
      ),
    );

    await storage.set(StorageConstant.email, result.email ?? '');
    await storage.set(StorageConstant.userName, result.name ?? '');
    await storage.set(StorageConstant.userId, result.id?.toString() ?? '');
    await storage.setList(StorageConstant.permissions, result.permissions ?? []);
      
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
      // Even if logout fails, still update local state
      isLoggedIn.value = false;
    }
  }
}
