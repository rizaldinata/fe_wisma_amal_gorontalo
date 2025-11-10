import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';

import 'core/navigation/go_router.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDependencies();
 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = serviceLocator<AuthBloc>();
    
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Wisma Amal',
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        theme: ThemeData(
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        routerConfig: AppRouter(authBloc: authBloc).router,
      ),
    );
  }
}
