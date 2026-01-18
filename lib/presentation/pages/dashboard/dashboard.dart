import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/pages/dashboard/widget/stat_data.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              const StatData(),
              const SizedBox(height: 24),
              TableCard(
                title: 'Jadwal Perawatan',
                columns: const [
                  TableColumn(label: 'Nama Teknisi', flex: 2),
                  TableColumn(label: 'Kamar'),
                  TableColumn(label: 'Sub Tipe'),
                  TableColumn(label: 'Tanggal'),
                  TableColumn(label: 'Status'),
                ],
                rows: [
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                ],
              ),
              SizedBox(height: 24),
              TableCard(
                title: 'Jadwal Perawatan',
                columns: const [
                  TableColumn(label: 'Nama Teknisi', flex: 2),
                  TableColumn(label: 'Kamar'),
                  TableColumn(label: 'Sub Tipe'),
                  TableColumn(label: 'Tanggal'),
                  TableColumn(label: 'Status'),
                ],
                rows: [
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Maintenance',
                    '20-05-2025',
                    'Selesai',
                  ],
                  [
                    'Budi Santoso',
                    'A301',
                    'Perbaikan',
                    '20-05-2025',
                    'Selesai',
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
