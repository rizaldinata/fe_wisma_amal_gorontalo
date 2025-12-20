import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/app_snackbar.dart';
import 'package:frontend/presentation/widget/core/button.dart';
import 'package:frontend/presentation/widget/core/textform.dart';

@RoutePage()
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
                // height: 700,
                width: 600,
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state.status.isFailure) {
                      AppSnackbar.showError(
                        state.errorMessage ?? 'Register failed',
                      );
                    }
                    // Navigate to dashboard ketika register berhasil
                    if (state.isLoggedIn && state.errorMessage == null) {
                      print('Login successful, navigating to dashboard...');
                      context.router.pushAndPopUntil(
                        AppLayoutRoute(),
                        predicate: (_) => false,
                      );
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username tidak boleh kosong';
                              }

                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          CustomTextForm(
                            controller: emailController,
                            title: 'Email',
                            hintText: 'johnDoe@mail.com',
                            isRequired: true,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!RegExp(
                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
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
                          SizedBox(height: 20),
                          CustomTextForm(
                            controller: passwordConfirmController,
                            title: 'Konfirmasi Password',
                            hintText: '***********',
                            isRequired: true,
                            obscureText: state.obscureText,
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30),
                          BasicButton(
                            onPressed: state.status.isInProgress
                                ? null
                                : () async {
                                    // Jalankan validator
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      // Kalau valid, kirim event register
                                      context.read<AuthBloc>().add(
                                        RegisterEvent(
                                          username: usernameController.text,
                                          email: emailController.text,
                                          password: passwordController.text,
                                          passwordConfirm:
                                              passwordConfirmController.text,
                                        ),
                                      );
                                    } else {
                                      // Kalau tidak valid, tampilkan snackbar error
                                      AppSnackbar.showError(
                                        'Periksa kembali data yang kamu masukkan',
                                      );
                                    }
                                  },
                            label: state.status.isInProgress
                                ? 'Loading...'
                                : 'Register',
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
                                  context.router.replace(LoginRoute());
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
