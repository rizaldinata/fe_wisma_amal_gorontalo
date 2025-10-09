import 'package:flutter/material.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/presentation/get/auth/auth_controller.dart';
import 'package:get/get.dart';

import 'core/navigation/go_router.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDependencies();
  
  // Inisialisasi AuthController sebelum router
  Get.put(AuthController(
    auth: serviceLocator<AuthDatasource>(),
  ));
 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wisma Amal',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: AppRouter().router,
    );
  }
}
