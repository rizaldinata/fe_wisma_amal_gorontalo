import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/button.dart';
import 'package:frontend/presentation/widget/textform.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Toggle obscure text saat pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const ToggleObscureTextEvent());
    });
    
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
                height: 700,
                width: 600,
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // Navigate to dashboard ketika register berhasil
                    if (state.isLoggedIn && state.successMessage != null) {
                      print('Register successful, navigating to dashboard...');
                      context.go(RouteConstant.dashboardPath);
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      child: Column(
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
                            'Daftar akun baru untuk melanjutkan',
                            style: StyleConstant.customTextStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 30),
                          CustomTextForm(
                            controller: usernameController,
                            title: 'Username',
                            hintText: 'John Doe',
                            isRequired: true,
                          ),
                          SizedBox(height: 20),
                          CustomTextForm(
                            controller: emailController,
                            title: 'Email',
                            hintText: 'johnDoe@mail.com',
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 20),
                          CustomTextForm(
                            controller: passwordController,
                            title: 'Password',
                            hintText: '***********',
                            isRequired: true,
                            obscureText: state.obscureText,
                            suffixIcon: IconButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      const ToggleObscureTextEvent(),
                                    );
                              },
                              icon: Icon(
                                !state.obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomTextForm(
                            controller: passwordConfirmController,
                            title: 'Konfirmasi Password',
                            hintText: '***********',
                            isRequired: true,
                            obscureText: state.obscureText,
                          ),
                          SizedBox(height: 30),
                          BasicButton(
                            onPressed: state.isLoading
                                ? null
                                : () async {
                                    print('Register pressed');
                                    if (emailController.text.isEmpty ||
                                        usernameController.text.isEmpty ||
                                        passwordController.text.isEmpty ||
                                        passwordConfirmController
                                            .text.isEmpty) {
                                      print('Field is empty');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Semua field harus diisi',
                                          ),
                                          backgroundColor:
                                              Colors.red.withOpacity(0.8),
                                        ),
                                      );
                                    } else if (passwordController.text !=
                                        passwordConfirmController.text) {
                                      print('Password not match');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password tidak cocok',
                                          ),
                                          backgroundColor:
                                              Colors.red.withOpacity(0.8),
                                        ),
                                      );
                                    } else {
                                      context.read<AuthBloc>().add(
                                            RegisterEvent(
                                              username:
                                                  usernameController.text,
                                              email: emailController.text,
                                              password:
                                                  passwordController.text,
                                              passwordConfirm:
                                                  passwordConfirmController
                                                      .text,
                                            ),
                                          );
                                    }
                                  },
                            label: state.isLoading ? 'Loading...' : 'Register',
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
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
