// router/auth_guard.dart
import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/repository/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  AuthRepository authRepository;

  AuthGuard(this.authRepository);
  final SharedPrefsStorage storage = serviceLocator.get<SharedPrefsStorage>();

  bool isLoggedIn() {
    final token = storage.getToken();
    return token != null;
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (isLoggedIn()) {
      resolver.next();
    } else {
      router.push(LoginRoute());
    }
  }
}
