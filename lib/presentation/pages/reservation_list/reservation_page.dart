import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_bloc.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';
import 'package:frontend/presentation/pages/reservation_list/widget/reservation_card.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';

@RoutePage()
class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationBloc()..add(GetReservationsEvent()),
      child: const ReservationView(),
    );
  }
}

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── STAT CARDS ──
                  Row(
                    children: [
                      StatCard(
                        title: 'Total Reservasi',
                        count: state.reservations.length.toString(),
                        color: Colors.green.shade100,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Aktif',
                        count: state.aktifReservations.length.toString(),
                        color: colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Pending',
                        count: state.pendingReservations.length.toString(),
                        color: Colors.orange.shade100,
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Selesai',
                        count: state.selesaiReservations.length.toString(),
                        color: colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // ── TAB BAR + TOMBOL ──
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _controller,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                            ),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: 'Semua'),
                              Tab(text: 'Aktif'),
                              Tab(text: 'Pending'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      BasicButton(
                        onPressed: () {
                          // TODO: navigasi ke form tambah reservasi
                        },
                        label: 'Tambah Reservasi',
                        leadIcon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── CONTENT ──
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final List<Map<String, dynamic>> currentReservations;
                      switch (_controller.index) {
                        case 0:
                          currentReservations = state.reservations;
                          break;
                        case 1:
                          currentReservations = state.aktifReservations;
                          break;
                        case 2:
                          currentReservations = state.pendingReservations;
                          break;
                        default:
                          currentReservations = state.reservations;
                      }
                      return _buildReservationList(currentReservations, state);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationList(
    List<Map<String, dynamic>> reservations,
    ReservationState state,
  ) {
    if (state.status == FormzSubmissionStatus.inProgress) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == FormzSubmissionStatus.failure) {
      return Center(
        child: Text(
          'Gagal memuat reservasi: ${state.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (reservations.isEmpty) {
      return BasicCard(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.book_online_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ada reservasi',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BasicCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final item = reservations[index];
          return ReservationCard(
            guestName: item['guestName'] ?? '',
            roomTitle: item['roomTitle'] ?? '',
            checkIn: item['checkIn'] ?? '',
            checkOut: item['checkOut'] ?? '',
            status: item['status'] ?? '',
            onTap: () {},
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}