// router/auth_guard.dart
import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/domain/repository/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  AuthRepository authRepository;

  AuthGuard(this.authRepository);
  final SecureStorageService storage = serviceLocator
      .get<SecureStorageService>();

  Future<bool> isLoggedIn() async {
    final token = await storage.get(StorageConstant.token);
    return token != null;
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    isLoggedIn().then((loggedIn) {
      if (loggedIn) {
        resolver.next();
      } else {
        router.navigate(LoginRoute());
      }
    });
  }
}
