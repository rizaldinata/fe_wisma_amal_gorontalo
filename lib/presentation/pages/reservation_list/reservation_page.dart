import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _ReservationViewState extends State<ReservationView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SingleChildScrollView(
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
                          title: 'Total kamar',
                          count: '10',
                          icon: const Icon(
                            Icons.bed_outlined,
                            size: 24,
                            color: Color(0xFF3F51B5),
                          ),
                          color: const Color(0xFFC5CAE9),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: StatCard(
                          title: 'Reservasi Masuk',
                          count: '3',
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
                          title: 'Pembayaran Valid',
                          count: '10',
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
                    actions: _buildHeaderFilters(context),
                    columns: const [
                      TableColumn(label: 'Id', flex: 1),
                      TableColumn(label: 'Nama', flex: 3),
                      TableColumn(label: 'kamar', flex: 1),
                      TableColumn(label: 'Jenis Sewa', flex: 2),
                      TableColumn(label: 'Periode', flex: 4),
                      TableColumn(label: 'Status Pembayaran', flex: 3),
                      TableColumn(label: 'Action', flex: 1),
                    ],
                    rows: List.generate(
                      5,
                      (index) => [
                        'RSV001',
                        'Bagus Alfian',
                        'A201',
                        'Harian',
                        '12 Feb 2025 - 18 Feb 2025',
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: ReservationStatusBadge(status: 'Lunas'),
                        ),
                        _buildEditButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderFilters(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 250,
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(
          hint: 'Urutkan',
          icon: Icons.filter_list,
          width: 110,
        ),
        const SizedBox(width: 12),
        const _SmallFilterDropdown(hint: '1 February 2025', width: 160),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.remove, size: 16),
        ),
        const _SmallFilterDropdown(hint: '1 Maret 2025', width: 160),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: () {},
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

class _SmallFilterDropdown extends StatelessWidget {
  final String hint;
  final IconData? icon;
  final double width;

  const _SmallFilterDropdown({
    required this.hint,
    this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Expanded(
            child: Text(
              hint,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
