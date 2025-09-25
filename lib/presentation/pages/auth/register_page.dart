import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/presentation/widget/button.dart';
import 'package:frontend/presentation/widget/textform.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                      'Masukan Email dan Password untuk melanjutkan',
                      style: StyleConstant.customTextStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    // Spacer(),
                    SizedBox(height: 40),
                    CustomTextForm(
                      title: 'Email',
                      hintText: 'johnDoe@mail.com',
                      isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    CustomTextForm(
                      title: 'Password',
                      hintText: '***********',
                      isRequired: true,
                    ),
                    SizedBox(height: 20),
                    CustomTextForm(
                      title: 'konfirmasi Password',
                      hintText: '***********',
                      isRequired: true,
                    ),
                    SizedBox(height: 40),

                    BasicButton(
                      onPressed: () {
                        context.go(RouteConstant.login);
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
                            context.go(RouteConstant.login);
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
        ],
      ),
    );
  }
}
