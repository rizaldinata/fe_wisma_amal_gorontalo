import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../domain/entity/finance/expense_entity.dart';
import '../../bloc/expense/expense_bloc.dart';
import '../../bloc/expense/expense_event.dart';
import '../../bloc/expense/expense_state.dart';
import '../../widget/core/card/basic_card.dart';
import '../../widget/core/chip/custom_chip.dart';

@RoutePage()
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({Key? key}) : super(key: key);

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late ExpenseBloc _expenseBloc;

  @override
  void initState() {
    super.initState();
    _expenseBloc = serviceLocator.get<ExpenseBloc>();
    _expenseBloc.add(FetchExpenses());
  }

  @override
  void dispose() {
    // Pastikan di file dependency_injection.dart, ExpenseBloc didaftarkan sebagai Factory
    // serviceLocator.registerFactory(() => ExpenseBloc(...));
    _expenseBloc.close();
    super.dispose();
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _showExpenseDialog([ExpenseEntity? expense]) {
    final titleController = TextEditingController(text: expense?.title);
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final categoryController = TextEditingController(text: expense?.category);
    final notesController = TextEditingController(text: expense?.notes);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(expense == null ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul/Nama Pengeluaran'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final nominal = double.tryParse(amountController.text) ?? 0.0;
                final date = expense?.date ?? DateTime.now().toIso8601String();
                
                final newExpense = ExpenseEntity(
                  id: expense?.id ?? 0,
                  title: titleController.text,
                  amount: nominal,
                  date: date,
                  category: categoryController.text,
                  notes: notesController.text,
                );

                if (expense == null) {
                  _expenseBloc.add(CreateExpense(newExpense));
                } else {
                  _expenseBloc.add(UpdateExpense(newExpense));
                }
                
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(ExpenseEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus "${expense.title}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                _expenseBloc.add(DeleteExpense(expense.id));
                Navigator.pop(ctx);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _expenseBloc,
      child: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Tambahkan pemanggilan fetch ulang data di sini setelah operasi sukses
            _expenseBloc.add(FetchExpenses());
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Manajemen Pengeluaran'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showExpenseDialog(),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              buildWhen: (previous, current) => current is ExpenseLoading || current is ExpenseLoaded || current is ExpenseInitial,
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpenseLoaded) {
                  if (state.expenses.isEmpty) {
                    return const Center(child: Text('Belum ada data pengeluaran.'));
                  }
                  return ListView.builder(
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
                      return BasicCard(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.red.shade100,
                            child: Icon(Icons.outbound, color: Colors.red.shade700),
                          ),
                          title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('dd MMM yyyy').format(DateTime.parse(expense.date))),
                              if (expense.category != null && expense.category!.isNotEmpty)
                                CustomChip(label: expense.category!, color: Colors.grey.shade200),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatRupiah(expense.amount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              
                              if (expense.isIntegrated)
                                CustomChip(label: 'Sistem', color: Colors.blue.shade100)
                              else
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showExpenseDialog(expense);
                                    } else if (value == 'delete') {
                                      _confirmDelete(expense);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Text('Ubah')),
                                    const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}