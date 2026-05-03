import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:frontend/core/dependency_injection/dependency_injection.dart';

import 'package:frontend/presentation/bloc/my_reservation/my_reservation_bloc.dart';
import 'package:frontend/presentation/bloc/my_reservation/my_reservation_state.dart';

@RoutePage()
class MyReservationPage extends StatelessWidget {
  const MyReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MyReservationBloc>(),

      child: Scaffold(
        appBar: AppBar(title: const Text('Reservasi Saya')),

        body: BlocBuilder<MyReservationBloc, MyReservationState>(
          builder: (context, state) {
            if (state.status == FormzSubmissionStatus.inProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == FormzSubmissionStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? 'Terjadi kesalahan'),
              );
            }

            if (state.reservations.isEmpty) {
              return const Center(child: Text('Belum ada reservasi'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: state.reservations.length,

              itemBuilder: (context, index) {
                final reservation = state.reservations[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: Colors.grey.shade200),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),

                        blurRadius: 10,

                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(18),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: const Icon(
                                Icons.meeting_room_outlined,

                                color: Colors.deepPurple,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    reservation.roomTitle,

                                    style: const TextStyle(
                                      fontSize: 17,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    'Room ${reservation.roomNumber}',

                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      'Check In',

                                      style: TextStyle(
                                        fontSize: 12,

                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      reservation.startDate,

                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.arrow_forward_rounded,

                                color: Colors.grey.shade400,
                              ),

                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,

                                    children: [
                                      Text(
                                        'Check Out',

                                        style: TextStyle(
                                          fontSize: 12,

                                          color: Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        reservation.endDate,

                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
