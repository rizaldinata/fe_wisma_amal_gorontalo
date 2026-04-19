import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../bloc/invoice/invoice_bloc.dart';
import '../../bloc/invoice/invoice_event.dart';
import '../../bloc/invoice/invoice_state.dart';
import '../../widget/core/card/basic_card.dart';

@RoutePage()
class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  late InvoiceBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator.get<InvoiceBloc>();
    _bloc.add(FetchInvoices());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  String formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> _printPdf(int invoiceId) async {
    // URL ini pada versi produksi harus memuat properti token otorisasi jika dilindungi middleware!
    // Untuk tahap ini disimulasikan sebagai request biasa via url_launcher
    final url = Uri.parse('http://127.0.0.1:8000/api/v1/finance/invoices/$invoiceId/print');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka URL pencetakan.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Rekap Tagihan (Invoices)'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<InvoiceBloc, InvoiceState>(
            builder: (context, state) {
              if (state is InvoiceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is InvoiceError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is InvoiceLoaded) {
                if (state.invoices.isEmpty) {
                  return const Center(child: Text('Tidak ada tagihan ditemukan.'));
                }

                return ListView.builder(
                  itemCount: state.invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = state.invoices[index];
                    final dateString = invoice.dueDate.toString();
                    final formattedDate = dateString.isNotEmpty 
                        ? DateFormat('dd MMM yyyy').format(DateTime.tryParse(dateString) ?? DateTime.now())
                        : 'Tanggal tidak valid';

                    final isPaid = invoice.status.toLowerCase() == 'paid';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: BasicCard(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: isPaid ? Colors.green : Colors.redAccent,
                            child: Icon(isPaid ? Icons.check : Icons.warning_amber_rounded, color: Colors.white),
                          ),
                          title: Text('Tagihan #${invoice.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Nominal: ${formatRupiah(invoice.amount)}'),
                              Text('Tenggat Waktu: $formattedDate\nStatus: ${invoice.status.toUpperCase()}'),
                            ],
                          ),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.print, size: 18),
                            label: const Text('Cetak Nota'),
                            onPressed: () => _printPdf(invoice.id),
                          ),
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
    );
  }
}
