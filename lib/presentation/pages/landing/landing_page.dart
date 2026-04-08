import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart'; // Pastikan import BasicButton

@RoutePage()
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisma Amal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    state.isLoggedIn
                        ? 'Halo, ${state.userInfo?.name ?? "User"}!'
                        : 'Selamat Datang di Wisma Amal',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    state.isLoggedIn
                        ? 'Anda sedang dalam mode User/Penghuni.'
                        : 'Silakan login untuk mengakses fitur sewa dan pembayaran.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  if (!state.isLoggedIn) ...[
                    SizedBox(
                      width: 200,
                      child: BasicButton(
                        onPressed: () {
                          context.router.navigate(LoginRoute());
                        },
                        label: 'Masuk / Daftar',
                        leadIcon: const Icon(Icons.login, color: Colors.white),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: 200,
                      child: BasicButton(
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(const LogoutEvent());
                        },
                        label: 'Logout',
                        leadIcon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
