// router/auth_guard.dart
import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/data/repository/auth_repository.dart';

class AuthGuard extends AutoRouteGuard {
  AuthRepository authRepository;

  AuthGuard(this.authRepository);

  @override
  void onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) {
    bool isLoggedIn = authRepository.isLoggedIn();
    if (isLoggedIn) {
      resolver.next();
    } else {
      router.push(LoginRoute());
    }
  }
}
