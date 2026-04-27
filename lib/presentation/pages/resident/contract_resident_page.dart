import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'widget/resident_table_action.dart';

@RoutePage()
class ContractResidentPage extends StatefulWidget {
  const ContractResidentPage({super.key});

  @override
  State<ContractResidentPage> createState() => _ContractResidentPageState();
}

class _ContractResidentPageState extends State<ContractResidentPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Semua';
  String _selectedPayment = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_ContractRowData> contractRows = [
      const _ContractRowData(
        id: '1',
        nama: 'John Doe',
        kamar: 'A1',
        identitas: '1234567890',
        masuk: '2023-01-01',
        keluar: '2024-01-01',
      )
    ];

    return Scaffold(
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
                      ResidentTableAction(
                        searchController: _searchController,
                        onSearchChanged: (_) => setState(() {}),
                        selectedStatus: _selectedStatus,
                        selectedPayment: _selectedPayment,
                        onStatusChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                        onPaymentChanged: (value) {
                          setState(() {
                            _selectedPayment = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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

// Data Model
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