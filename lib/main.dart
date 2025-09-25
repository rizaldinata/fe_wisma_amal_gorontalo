import 'package:flutter/material.dart';
import 'package:frontend/presentation/get/auth/auth_controller.dart';
import 'package:get/get.dart';

import 'core/navigation/go_router.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  var controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Wisma Amal',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routerConfig: AppRouter().router,
    );
  }
}
