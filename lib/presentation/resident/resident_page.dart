import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/presentation/widget/core/card/basic_card.dart';
import 'widget/resident_table_action.dart';

@RoutePage()
class ResidentPage extends StatelessWidget {
  const ResidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final residentRows = List<_ResidentRowData>.generate(9, (index) {
      final isBelumLunas = index == 5;
      final isPending = index == 7;
      return _ResidentRowData(
        id: '1',
        nama: 'Dwi Rahmawati',
        kamar: 'AC203',
        kontak: '0812-3456-7890',
        detailBayar: isBelumLunas ? 'Belum Lunas' : 'Lunas',
        isBelumLunas: isBelumLunas,
        status: isPending ? 'Pending' : 'Aktif',
        isPending: isPending,
      );
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Penghuni',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                height: 1,
                color: const Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ResidentStatCard(
                    title: 'Penghuni Aktif',
                    count: '48',
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF5D6ACD),
                    iconBackgroundColor: const Color(0xFFD6DDFD),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ResidentStatCard(
                    title: 'Kontrak Pending',
                    count: '3',
                    icon: Icons.note_add_outlined,
                    iconColor: const Color(0xFF8A6400),
                    iconBackgroundColor: const Color(0xFFF6DEB3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ResidentStatCard(
                    title: 'Kontrak Akan Berakhir',
                    count: '2',
                    icon: Icons.event_note_outlined,
                    iconColor: const Color(0xFF248746),
                    iconBackgroundColor: const Color(0xFFB9EEC8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ResidentStatCard(
                    title: 'kamar Tersedia',
                    count: '12',
                    icon: Icons.bedroom_parent_outlined,
                    iconColor: const Color(0xFF248746),
                    iconBackgroundColor: const Color(0xFFB9EEC8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            BasicCard(
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
                          color: const Color(0xFFA794F2),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Penghuni',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 33,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF141414),
                        ),
                      ),
                      const Spacer(),
                      const ResidentTableAction(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E7E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        _HeaderCell(
                          label: 'ID',
                          flex: 1,
                          align: TextAlign.left,
                        ),
                        _HeaderCell(
                          label: 'NAMA',
                          flex: 4,
                          align: TextAlign.left,
                        ),
                        _HeaderCell(
                          label: 'KAMAR',
                          flex: 2,
                          align: TextAlign.left,
                          showSort: true,
                        ),
                        _HeaderCell(
                          label: 'KONTAK',
                          flex: 3,
                          align: TextAlign.left,
                        ),
                        _HeaderCell(
                          label: 'DETIL BAYAR',
                          flex: 2,
                          align: TextAlign.center,
                        ),
                        _HeaderCell(
                          label: 'STATUS',
                          flex: 2,
                          align: TextAlign.center,
                        ),
                        _HeaderCell(
                          label: 'AKSI',
                          flex: 2,
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...residentRows.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _BodyCell(value: row.id, flex: 1),
                          _BodyCell(value: row.nama, flex: 4),
                          _BodyCell(value: row.kamar, flex: 2),
                          _BodyCell(value: row.kontak, flex: 3),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: _StatusChip(
                                label: row.detailBayar,
                                color: row.isBelumLunas
                                    ? const Color(0xFFD20F0F)
                                    : const Color(0xFF18BF10),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.center,
                              child: _StatusChip(
                                label: row.status,
                                color: row.isPending
                                    ? const Color(0xFFE3A10E)
                                    : const Color(0xFF18BF10),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ActionSquareButton(
                                  backgroundColor: const Color(0xFF2E80F7),
                                  icon: Icons.edit,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                                _ActionSquareButton(
                                  backgroundColor: const Color(0xFFD61111),
                                  icon: Icons.delete_outline,
                                  onPressed: () {},
                                ),
                              ],
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

class _ResidentStatCard extends StatelessWidget {
  const _ResidentStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return BasicCard(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF8B8B8B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2D2D),
                  height: 1,
                ),
              ),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
        ],
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
  const _BodyCell({required this.value, required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          value,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w600,
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

class _ResidentRowData {
  const _ResidentRowData({
    required this.id,
    required this.nama,
    required this.kamar,
    required this.kontak,
    required this.detailBayar,
    required this.isBelumLunas,
    required this.status,
    required this.isPending,
  });

  final String id;
  final String nama;
  final String kamar;
  final String kontak;
  final String detailBayar;
  final bool isBelumLunas;
  final String status;
  final bool isPending;
}
