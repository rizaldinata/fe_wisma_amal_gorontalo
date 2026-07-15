import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecase/finance/get_invoices_usecase.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final GetInvoicesUseCase getInvoicesUseCase;

  InvoiceBloc({required this.getInvoicesUseCase}) : super(InvoiceInitial()) {
    on<FetchInvoices>((event, emit) async {
      emit(InvoiceLoading());
      try {
        final invoices = await getInvoicesUseCase.call();
        emit(InvoiceLoaded(invoices));
      } catch (e) {
        emit(InvoiceError(e.toString()));
      }
    });
  }
}
