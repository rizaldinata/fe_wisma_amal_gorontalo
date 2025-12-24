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
import 'package:auto_route/auto_route.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, @QueryParam('reason') this.reason});

  final String? reason;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tampilkan SnackBar setelah widget selesai di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.reason == 'unauthenticated') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anda harus login untuk melanjutkan.'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    });

    // Toggle obscure text saat pertama kali
    context.read<AuthBloc>().add(const ToggleObscureTextEvent());
  }

  @override
  Widget build(BuildContext context) {
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
              constraints: BoxConstraints(maxWidth: 700),
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
                    if (state.status.isFailure) {
                      AppSnackbar.showError(
                        state.errorMessage ?? 'Login failed',
                      );
                    }

                    // LOGIC REDIRECT BERDASARKAN PERMISSION
                    if (state.isLoggedIn &&
                        state.userInfo != null &&
                        state.errorMessage == null) {
                      final permissions = state.userInfo?.permissions ?? [];

                      print('User Permissions: $permissions'); // Debugging

                      // Cek apakah punya akses Admin Panel
                      if (permissions.contains('access_admin_panel')) {
                        print('Role: ADMIN -> Navigasi ke Dashboard');
                        context.router.pushAndPopUntil(
                          const AppLayoutRoute(),
                          predicate: (_) => false,
                        );
                      } else {
                        print('Role: USER/GUEST -> Navigasi ke Landing Page');
                        context.router.pushAndPopUntil(
                          const LandingRoute(),
                          predicate: (_) => false,
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login Page',
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
                        SizedBox(height: 40),
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
                        SizedBox(height: 40),
                        BasicButton(
                          onPressed: state.status.isInProgress
                              ? null
                              : () async {
                                  print('Login pressed');
                                  if (emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    print('Email or Password is empty');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Email dan password harus diisi',
                                        ),
                                        backgroundColor: Colors.red.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    );
                                  } else {
                                    context.read<AuthBloc>().add(
                                      LoginEvent(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                    );
                                  }
                                },
                          label: state.status.isInProgress
                              ? 'Loading...'
                              : 'Login',
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun?',
                              style: StyleConstant.customTextStyle,
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.replace(RegisterRoute());
                              },
                              child: Text('Daftar disini'),
                            ),
                          ],
                        ),
                      ],
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
