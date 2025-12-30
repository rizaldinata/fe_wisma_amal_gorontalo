import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';

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
      value: authBloc,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Wisma Amal',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router.config(),
      ),
    );
  }
}
