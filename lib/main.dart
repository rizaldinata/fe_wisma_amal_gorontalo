import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:frontend/presentation/bloc/app/app_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await initializeDependencies();
  usePathUrlStrategy();

  const storage = FlutterSecureStorage();

  await storage.write(key: 'ping', value: 'pong');
  final v = await storage.read(key: 'ping');

  print('STORAGE TEST: $v');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: serviceLocator<AuthBloc>()..add(InitLoginStatusEvent()),
        ),
        BlocProvider(create: (context) => AppBloc()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select((AppBloc bloc) => bloc.state.isDarkMode);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wisma Amal',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      // builder: (context, child) {
      //   return SessionListener(router: router, child: child!);
      // },
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router.config(),
    );
  }
}

extension PermissionContext on BuildContext {
  bool can(String permission) {
    final auth = watch<AuthBloc>().state;
    print('Checking permission: $permission');
    print('User permissions: ${auth.userInfo?.permissions?.raw}');
    return auth.userInfo?.permissions?.can(permission) ?? false;
  }
}

// class SessionListener extends StatelessWidget {
//   final Widget child;
//   final AppRouter router;

//   const SessionListener({super.key, required this.child, required this.router});

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         print(
//           'SessionListener: Auth state changed: isLoggedIn=${state.isLoggedIn}',
//         );
//         if (state.isLoggedIn) {
//           router.replaceAll([const DashboardRoute()]);
//         } else {
//           router.replaceAll([LoginRoute()]);
//         }
//       },
//       child: child,
//     );
//   }
// }
