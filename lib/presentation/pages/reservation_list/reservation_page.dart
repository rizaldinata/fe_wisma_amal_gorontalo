import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/dependency_injection/dependency_injection.dart';

import 'package:frontend/domain/entity/reservation_entity.dart';

import 'package:frontend/domain/entity/table/tabel_colum.dart';

import 'package:frontend/presentation/bloc/reservation_list/reservation_bloc.dart';

import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';

import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';

import 'package:frontend/presentation/pages/reservation_list/widget/reservation_status_badge.dart';

import 'package:frontend/presentation/widget/core/card/stat_card.dart';

import 'package:frontend/presentation/widget/core/table/table.dart';

@RoutePage()
class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<ReservationBloc>()..add(GetReservationsEvent()),

      child: const ReservationView(),
    );
  }
}

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  final TextEditingController _searchController = TextEditingController();

  DateTime? selectedStartDate;

  DateTime? selectedEndDate;

  String selectedSort = 'all';

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });

      BlocProvider.of<ReservationBloc>(this.context).add(
        FilterReservationDateEvent(
          startDate: selectedStartDate,

          endDate: selectedEndDate,
        ),
      );
    }
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
      });

      BlocProvider.of<ReservationBloc>(this.context).add(
        FilterReservationDateEvent(
          startDate: selectedStartDate,

          endDate: selectedEndDate,
        ),
      );
    }
  }

  void _showEditStatusDialog(ReservationEntity reservation) {
    String selectedStatus = reservation.status;

    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status Reservasi'),

          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButtonFormField<String>(
                value: selectedStatus,

                decoration: const InputDecoration(labelText: 'Status'),

                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),

                  DropdownMenuItem(value: 'active', child: Text('Active')),

                  DropdownMenuItem(
                    value: 'cancelled',

                    child: Text('Cancelled'),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    setModalState(() {
                      selectedStatus = value;
                    });
                  }
                },
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Batal'),
            ),

            ElevatedButton(
              onPressed: () {
                BlocProvider.of<ReservationBloc>(this.context).add(
                  UpdateReservationStatusEvent(
                    reservationId: reservation.id,
                    status: selectedStatus,
                  ),
                );

                Navigator.pop(context);
              },

              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,

          body: state.status.toString().contains('inProgress')
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Data Reservasi',

                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Kelola Sistem Kost Anda dengan Mudah',

                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Total Reservasi',
                                count: state.reservations.length.toString(),
                                color: Colors.green.shade100,
                                icon: const Icon(Icons.bed_outlined),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: StatCard(
                                title: 'Reservasi Pending',

                                count: state.pendingReservations.length
                                    .toString(),

                                icon: const Icon(
                                  Icons.insert_drive_file_outlined,

                                  size: 24,

                                  color: Color(0xFFFFA000),
                                ),

                                color: const Color(0xFFFFECB3),
                              ),
                            ),

                            const SizedBox(width: 20),

                            Expanded(
                              child: StatCard(
                                title: 'Reservasi Aktif',

                                count: state.activeReservations.length
                                    .toString(),

                                icon: const Icon(
                                  Icons.assignment_turned_in_outlined,

                                  size: 24,

                                  color: Color(0xFF43A047),
                                ),

                                color: const Color(0xFFDCEDC8),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        TableCard(
                          title: 'Data Reservasi',

                          actions: _buildHeaderFilters(),

                          columns: const [
                            TableColumn(label: 'ID', flex: 1),

                            TableColumn(label: 'Nama Penghuni', flex: 3),

                            TableColumn(label: 'Nomor Kamar', flex: 2),

                            TableColumn(label: 'Jenis Sewa', flex: 2),

                            TableColumn(label: 'Periode', flex: 4),

                            TableColumn(label: 'Status', flex: 2),

                            TableColumn(label: 'Action', flex: 1),
                          ],

                          rows: state.filteredReservations.map((reservation) {
                            return [
                              reservation.id.toString(),

                              reservation.residentName,

                              reservation.roomNumber,

                              reservation.rentalType,

                              '${reservation.startDate} - ${reservation.endDate}',

                              Align(
                                alignment: Alignment.centerLeft,

                                child: ReservationStatusBadge(
                                  status: reservation.status,
                                ),
                              ),

                              _buildEditButton(reservation),
                            ];
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            width: 250,

            height: 40,

            child: TextField(
              controller: _searchController,

              onChanged: (value) {
                BlocProvider.of<ReservationBloc>(
                  this.context,
                ).add(SearchReservationEvent(value));
              },

              decoration: InputDecoration(
                hintText: 'Cari penghuni / kamar',

                prefixIcon: const Icon(Icons.search, size: 20),

                contentPadding: const EdgeInsets.symmetric(vertical: 0),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 150,

            height: 40,

            padding: const EdgeInsets.symmetric(horizontal: 12),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),

              borderRadius: BorderRadius.circular(8),
            ),

            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,

                isExpanded: true,

                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Semua')),

                  DropdownMenuItem(value: 'pending', child: Text('Pending')),

                  DropdownMenuItem(value: 'active', child: Text('Active')),

                  DropdownMenuItem(
                    value: 'cancelled',
                    child: Text('Cancelled'),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSort = value;
                    });

                    BlocProvider.of<ReservationBloc>(
                      this.context,
                    ).add(SortReservationEvent(value));
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          InkWell(
            onTap: _pickStartDate,

            child: Container(
              width: 160,

              height: 40,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),

                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                selectedStartDate == null
                    ? 'Start Date'
                    : '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}',
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),

            child: Icon(Icons.remove, size: 16),
          ),

          InkWell(
            onTap: _pickEndDate,

            child: Container(
              width: 160,

              height: 40,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),

                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                selectedEndDate == null
                    ? 'End Date'
                    : '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(ReservationEntity reservation) {
    return SizedBox(
      height: 30,

      child: ElevatedButton(
        onPressed: () {
          _showEditStatusDialog(reservation);
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC107),

          foregroundColor: Colors.white,

          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        child: const Text('Edit', style: TextStyle(fontSize: 11)),
      ),
    );
  }
}
