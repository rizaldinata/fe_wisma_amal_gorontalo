import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  // Example methods to update the login state
  void login() {
    isLoggedIn.value = true;
  }

  // Example methods to update the login state
  void logout() {
    isLoggedIn.value = false;
  }
}
