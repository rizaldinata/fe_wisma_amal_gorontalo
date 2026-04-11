import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/bloc/inventory/inventory_list_bloc.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:intl/intl.dart';

@RoutePage()
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<InventoryListBloc>()..add(FetchInventories()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  String _formatCurrency(double? price) {
    if (price == null) return '-';
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: BlocBuilder<InventoryListBloc, InventoryListState>(
          builder: (context, state) {
            return SingleChildScrollView(
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
                        onPressed: () async {
                          final result = await context.router.push(InventoryFormRoute());
                          if (result == true && context.mounted) {
                            context.read<InventoryListBloc>().add(FetchInventories());
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Inventaris'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state is InventoryListLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is InventoryListError)
                    Center(child: Text('Gagal mengambil data: ${state.message}'))
                  else if (state is InventoryListLoaded) ...[
                    TableCard(
                      title: 'Daftar Barang',
                      columns: const [
                        TableColumn(label: 'Nama', flex: 2),
                        TableColumn(label: 'Keterangan', flex: 3),
                        TableColumn(label: 'Jumlah'),
                        TableColumn(label: 'Kondisi'),
                        TableColumn(label: 'Total Harga', flex: 2),
                        TableColumn(label: '', flex: 1),
                      ],
                      rows: state.inventories.map((item) {
                        return [
                          item.nama,
                          item.keterangan.isNotEmpty ? item.keterangan : '-',
                          item.jumlah.toString(),
                          item.kondisi.displayName,
                          _formatCurrency(item.purchasePrice),
                          _EditButton(
                            onPressed: () async {
                              final result = await context.router.push(
                                InventoryFormRoute(inventoryData: item),
                              );
                              if (result == true && context.mounted) {
                                context.read<InventoryListBloc>().add(FetchInventories());
                              }
                            },
                          ),
                        ];
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          },
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
