import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/widget/core/card/stat_card.dart';
import 'package:frontend/presentation/widget/core/botton/icon_button.dart';
import 'package:frontend/presentation/widget/core/chip/custom_chip.dart';
import 'package:frontend/presentation/widget/core/table/table.dart'; 
import 'widget/resident_table_action.dart';

@RoutePage()
class ResidentPage extends StatelessWidget {
  const ResidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar menyatu dengan background layout
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Halaman
            Text(
              'Daftar Penghuni',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 24),

            // Top Stat Cards Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Penghuni Aktif',
                    count: '48',
                    icon: const Icon(Icons.person_outline, color: Colors.indigo, size: 28),
                    color: Colors.indigo.shade50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Kontrak Pending',
                    count: '3',
                    icon: const Icon(Icons.note_add_outlined, color: Colors.orange, size: 28),
                    color: Colors.orange.shade50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Kontrak Akan Berakhir',
                    count: '2',
                    icon: const Icon(Icons.event_busy_outlined, color: Colors.green, size: 28),
                    color: Colors.green.shade50,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'kamar Tersedia',
                    count: '12',
                    icon: const Icon(Icons.bed_outlined, color: Colors.green, size: 28),
                    color: Colors.green.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Table
            TableCard(
              title: 'Penghuni',
              actions: const ResidentTableAction(), // Widget lokal yang baru kita buat
              columns: [
                TableColumn(label: 'ID', flex: 1),
                TableColumn(label: 'NAMA', flex: 3),
                TableColumn(label: 'KAMAR', flex: 2),
                TableColumn(label: 'KONTAK', flex: 3),
                TableColumn(label: 'DETIL BAYAR', flex: 2),
                TableColumn(label: 'STATUS', flex: 2),
                TableColumn(label: 'AKSI', flex: 2, align: TextAlign.center),
              ],
              rows: List.generate(8, (index) {
                // Simulasi data sesuai mockup
                bool isBelumLunas = index == 5;
                bool isPending = index == 6;

                return [
                  '1', // ID
                  'Dwi Rahmawati', // Nama
                  'AC203', // Kamar
                  '0812-3456-7890', // Kontak
                  
                  // Detil Bayar
                  CustomChip(
                    label: isBelumLunas ? 'Belum Lunas' : 'Lunas',
                    color: isBelumLunas ? Colors.red : Colors.green,
                  ),
                  
                  // Status
                  CustomChip(
                    label: isPending ? 'Pending' : 'Aktif',
                    color: isPending ? Colors.orange : Colors.green,
                  ),
                  
                  // Aksi Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                        backgroundColor: Colors.blue,
                        boxShadow: const [],
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      CustomIconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                        backgroundColor: Colors.red,
                        boxShadow: const [],
                        onPressed: () {},
                      ),
                    ],
                  ),
                ];
              }),
            ),
          ],
        ),
      ),
    );
  }
}