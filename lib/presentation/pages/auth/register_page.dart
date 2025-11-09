import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/presentation/get/auth/auth_controller.dart';
import 'package:frontend/presentation/widget/button.dart';
import 'package:frontend/presentation/widget/textform.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  var authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    authController.toggleObscureText();
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
              child: Row(
                children: [
                  Text(
                    'Wisma Amal',
                    style: StyleConstant.customTextStyle.copyWith(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 700, maxHeight: 1000),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                width: 600,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Register Page',
                        style: StyleConstant.customTextStyle.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Masukan Email dan Password untuk melanjutkan',
                        style: StyleConstant.customTextStyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      // Spacer(),
                      SizedBox(height: 40),
                      CustomTextForm(
                        title: 'Username',
                        hintText: 'John Doe',
                        isRequired: true,
                        controller: usernameController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomTextForm(
                        title: 'Email',
                        hintText: 'johnDoe@mail.com',
                        isRequired: true,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          // Regex sederhana untuk format email
                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      GetX<AuthController>(
                        initState: (_) => authController.toggleObscureText(),
                        builder: (_) => CustomTextForm(
                          title: 'Password',
                          hintText: '***********',
                          controller: passwordController,
                          isRequired: true,
                          suffixIcon: IconButton(
                            onPressed: () {
                              authController.toggleObscureText();
                            },
                            icon: Icon(
                              !authController.obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          obscureText: authController.obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Obx(
                        () => CustomTextForm(
                          title: 'konfirmasi Password',
                          controller: passwordConfirmController,
                          hintText: '***********',
                          isRequired: true,
                          obscureText: authController.obscureText,
                          suffixIcon: IconButton(
                            onPressed: () {
                              authController.toggleObscureText();
                            },
                            icon: Icon(
                              !authController.obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),

                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 40),

                      BasicButton(
                        onPressed: () {
                          authController.register(
                            username: usernameController.text,
                            email: emailController.text,
                            password: passwordConfirmController.text,
                            passwordConfirm: passwordConfirmController.text,
                          );

                          if (authController.isLoggedIn.value) {
                            context.go(RouteConstant.dashboardPath);
                          }
                        },
                        label: 'Login',
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun?',
                            style: StyleConstant.customTextStyle,
                          ),
                          TextButton(
                            onPressed: () {
                              context.goNamed(RouteConstant.loginName);
                            },
                            child: Text('Login disini'),
                          ),
                        ],
                      ),
                      // Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
