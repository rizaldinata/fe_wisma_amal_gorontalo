import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/inventory_entity.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';

@RoutePage()
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InventoryView();
  }
}

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  // TODO: Replace with real data from backend / BLoC
  static final List<InventoryEntity> _dummyInventory = [
    const InventoryEntity(
      nama: 'Sapu lantai',
      keterangan: 'Sapu lantai untuk lantai 2',
      jumlah: 3,
      kondisi: InventoryCondition.baik,
      jenis: InventoryType.umum,
      kategori: InventoryCategory.kebersihan,
    ),
    const InventoryEntity(
      nama: 'Galon air',
      keterangan: 'Galon air untuk lantai 3',
      jumlah: 4,
      kondisi: InventoryCondition.baik,
      jenis: InventoryType.umum,
      kategori: InventoryCategory.makananMinuman,
    ),
    const InventoryEntity(
      nama: 'Obeng Set',
      keterangan: 'Obeng perkakas',
      jumlah: 2,
      kondisi: InventoryCondition.cukup,
      jenis: InventoryType.alatKerja,
      kategori: InventoryCategory.alatKerja,
    ),
    const InventoryEntity(
      nama: 'Bor Listrik',
      keterangan: 'Bor listrik merk xiaomi',
      jumlah: 2,
      kondisi: InventoryCondition.cukup,
      jenis: InventoryType.alatKerja,
      kategori: InventoryCategory.alatKerja,
    ),
  ];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inventory',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.router.push(InventoryFormRoute());
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah Inventaris'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TableCard(
                title: 'Inventaris',
                columns: const [
                  TableColumn(label: 'Nama', flex: 2),
                  TableColumn(label: 'Keterangan', flex: 3),
                  TableColumn(label: 'Jumlah'),
                  TableColumn(label: 'Kondisi'),
                  TableColumn(label: 'Jenis'),
                  TableColumn(label: 'Kategori', flex: 2),
                  TableColumn(label: '', flex: 1),
                ],
                rows: _dummyInventory.map((item) {
                  return [
                    item.nama,
                    item.keterangan,
                    item.jumlah.toString(),
                    item.kondisi.displayName,
                    item.jenis.displayName,
                    item.kategori.displayName,
                    _EditButton(
                      onPressed: () {
                        context.router.push(
                          InventoryFormRoute(inventoryData: item),
                        );
                      },
                    ),
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 32,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4CC58),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 0,
          ),
          child: const Text('Edit', style: TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
