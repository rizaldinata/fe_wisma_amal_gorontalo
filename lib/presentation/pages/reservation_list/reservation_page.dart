import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_bloc.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_event.dart';
import 'package:frontend/presentation/bloc/reservation_list/reservation_state.dart';
import 'package:frontend/presentation/pages/reservation_list/widget/reservation_status_badge.dart';
import 'package:frontend/presentation/widget/core/card/summary_stat_card.dart';
import 'package:frontend/presentation/widget/core/table/app_data_table.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/appbar/search_and_filter_bar.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';

@RoutePage()
class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: serviceLocator<ReservationBloc>()..add(GetReservationsEvent()),
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

  void _applyDateFilter() {
    context.read<ReservationBloc>().add(
      FilterReservationDateEvent(
        startDate: selectedStartDate,
        endDate: selectedEndDate,
      ),
    );
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
      _applyDateFilter();
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
      _applyDateFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: isDark ? AppColorsDark.background : AppColorsLight.background,
          body: Column(
            children: [
              AppTopBar(
                title: 'Data Reservasi',
                breadcrumb: 'Kamar & Reservasi / Data Reservasi',
              ),
              Expanded(
                child: state.status == FormzSubmissionStatus.inProgress
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Total Reservasi',
                                    value: state.reservations.length.toString(),
                                    icon: Icons.bed_outlined,
                                    iconColor: isDark ? AppColorsDark.primary : AppColorsLight.primary,
                                    iconBg: isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Menunggu',
                                    value: state.pendingReservations.length.toString(),
                                    icon: Icons.insert_drive_file_outlined,
                                    iconColor: isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting,
                                    iconBg: isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: SummaryStatCard(
                                    label: 'Aktif',
                                    value: state.activeReservations.length.toString(),
                                    icon: Icons.assignment_turned_in_outlined,
                                    iconColor: isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone,
                                    iconBg: isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxxl),

                            SearchAndFilterBar(
                              searchHint: 'Cari penghuni / kamar...',
                              onSearchChanged: (value) {
                                context.read<ReservationBloc>().add(SearchReservationEvent(value));
                              },
                              dropdownFilter: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedSort,
                                        items: const [
                                          DropdownMenuItem(value: 'all', child: Text('Semua Status', style: TextStyle(fontSize: 14))),
                                          DropdownMenuItem(value: 'pending', child: Text('Menunggu', style: TextStyle(fontSize: 14))),
                                          DropdownMenuItem(value: 'active', child: Text('Aktif', style: TextStyle(fontSize: 14))),
                                          DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan', style: TextStyle(fontSize: 14))),
                                          DropdownMenuItem(value: 'finished', child: Text('Selesai', style: TextStyle(fontSize: 14))),
                                        ],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              selectedSort = value;
                                            });
                                            context.read<ReservationBloc>().add(SortReservationEvent(value));
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  InkWell(
                                    onTap: _pickStartDate,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                      child: Text(
                                        selectedStartDate == null
                                            ? 'Tgl Mulai'
                                            : '${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}',
                                        style: const TextStyle(fontSize: 14),
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
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                      child: Text(
                                        selectedEndDate == null
                                            ? 'Tgl Selesai'
                                            : '${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onSortPressed: () {},
                              sortLabel: '', // or hide
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            AppDataTable(
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('NAMA PENYEWA')),
                                DataColumn(label: Text('NO KAMAR')),
                                DataColumn(label: Text('JENIS SEWA')),
                                DataColumn(label: Text('PERIODE')),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('PEMBAYARAN')),
                              ],
                              rows: state.filteredReservations.map((reservation) {
                                return DataRow(cells: [
                                  DataCell(Text(reservation.id.toString())),
                                  DataCell(Text(reservation.residentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(reservation.roomNumber)),
                                  DataCell(Text(reservation.rentalType)),
                                  DataCell(Text('${reservation.startDate} - ${reservation.endDate}')),
                                  DataCell(ReservationStatusBadge(status: reservation.status)),
                                  DataCell(ReservationStatusBadge(
                                    status: reservation.paymentStatus,
                                    color: reservation.paymentStatus == 'paid'
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
