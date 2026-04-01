import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'widget/resident_table_action.dart';

@RoutePage()
class ContractResidentPage extends StatelessWidget {
  const ContractResidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate dummy data sesuai mockup
    final contractRows = List<_ContractRowData>.generate(8, (index) {
      return const _ContractRowData(
        id: '1',
        nama: 'Dwi Rahmawati',
        kamar: 'AC203',
        identitas: 'KTP',
        masuk: '12 Agustus 2024',
        keluar: '22 September 2025',
      );
    });

    return Scaffold(
      // Warna latar belakang abu-abu muda sesuai mockup
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Halaman
            Text(
              'Kontrak Sewa',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: const Color(0xFF121212),
                  ),
            ),
            const SizedBox(height: 32),

            // Kartu Tabel
            BasicCard(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.fromLTRB(34, 22, 34, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Header Tabel (Judul & Aksi)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA794F2), // Garis ungu pastel
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Penghuni', // Sesuai teks di dalam card pada mockup
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 33,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF141414),
                            ),
                      ),
                      const Spacer(),
                      // Memanggil widget Search & Filter lokal
                      const ResidentTableAction(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Header Kolom Tabel
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        _HeaderCell(label: 'ID', flex: 1, align: TextAlign.left),
                        _HeaderCell(label: 'NAMA', flex: 3, align: TextAlign.left),
                        _HeaderCell(label: 'KAMAR', flex: 2, align: TextAlign.center, showSort: true),
                        _HeaderCell(label: 'IDENTITAS', flex: 2, align: TextAlign.center),
                        _HeaderCell(label: 'MASUK', flex: 3, align: TextAlign.center),
                        _HeaderCell(label: 'KELUAR', flex: 3, align: TextAlign.center),
                        _HeaderCell(label: 'AKSI', flex: 1, align: TextAlign.center),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Isi Data Tabel
                  ...contractRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _BodyCell(value: row.id, flex: 1, align: TextAlign.left),
                          _BodyCell(value: row.nama, flex: 3, align: TextAlign.left),
                          _BodyCell(value: row.kamar, flex: 2, align: TextAlign.center),
                          _BodyCell(value: row.identitas, flex: 2, align: TextAlign.center),
                          _BodyCell(value: row.masuk, flex: 3, align: TextAlign.center),
                          _BodyCell(value: row.keluar, flex: 3, align: TextAlign.center),

                          // Kolom Aksi (Tombol icon Mata warna gelap)
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: _ActionSquareButton(
                                backgroundColor: const Color(0xFF141414), // Hitam gelap sesuai mockup
                                icon: Icons.visibility_outlined,
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRIVATE WIDGETS (Helper khusus untuk merender baris & kolom halaman ini)
// -----------------------------------------------------------------------------

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.flex,
    required this.align,
    this.showSort = false,
  });

  final String label;
  final int flex;
  final TextAlign align;
  final bool showSort;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: align == TextAlign.center
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: align,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F2F2F),
                ),
          ),
          if (showSort) ...[
            const SizedBox(width: 4),
            const Icon(Icons.unfold_more, size: 14, color: Color(0xFF2F2F2F)),
          ],
        ],
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({
    required this.value,
    required this.flex,
    required this.align,
  });

  final String value;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          value,
          textAlign: align,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: const Color(0xFF262626),
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

class _ActionSquareButton extends StatelessWidget {
  const _ActionSquareButton({
    required this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(3),
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: onPressed,
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

// Data Model Dummy
class _ContractRowData {
  const _ContractRowData({
    required this.id,
    required this.nama,
    required this.kamar,
    required this.identitas,
    required this.masuk,
    required this.keluar,
  });

  final String id;
  final String nama;
  final String kamar;
  final String identitas;
  final String masuk;
  final String keluar;
}