import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final authBloc = serviceLocator<AuthBloc>();

    return BlocProvider.value(
      value: authBloc..add(const CheckSessionEvent()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Wisma Amal',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return SessionListener(router: router, child: child!);
        },
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router.config(),
      ),
    );
  }
}

extension PermissionContext on BuildContext {
  bool can(String permission) {
    final auth = read<AuthBloc>().state;
    return auth.userInfo?.permissions?.can(permission) ?? false;
  }
}

class SessionListener extends StatelessWidget {
  final Widget child;
  final AppRouter router;

  const SessionListener({super.key, required this.child, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoggedIn) {
          router.replaceAll([const DashboardRoute()]);
        } else {
          router.replaceAll([LoginRoute()]);
        }
      },
      child: child,
    );
  }
}
