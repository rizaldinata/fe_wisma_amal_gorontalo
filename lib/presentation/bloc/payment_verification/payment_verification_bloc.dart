import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecase/finance/get_pending_payments_usecase.dart';
import '../../../../domain/usecase/finance/verify_payment_usecase.dart';
import '../../../../domain/usecase/finance/refund_payment_usecase.dart';
import 'payment_verification_event.dart';
import 'payment_verification_state.dart';

class PaymentVerificationBloc extends Bloc<PaymentVerificationEvent, PaymentVerificationState> {
  final GetPendingPaymentsUseCase getPendingPaymentsUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final RefundPaymentUseCase refundPaymentUseCase;

  PaymentVerificationBloc({
    required this.getPendingPaymentsUseCase,
    required this.verifyPaymentUseCase,
    required this.refundPaymentUseCase,
  }) : super(PaymentVerificationInitial()) {
    
    on<FetchPendingPayments>((event, emit) async {
      emit(PaymentVerificationLoading());
      try {
        final payments = await getPendingPaymentsUseCase.call(); 
        emit(PaymentVerificationLoaded(payments));
      } catch (e) {
        emit(PaymentVerificationError(e.toString()));
      }
    });

    on<VerifyPaymentEvent>((event, emit) async {
      emit(PaymentVerificationLoading());
      try {
        await verifyPaymentUseCase.call(
          event.paymentId, 
          event.isApproved, 
          adminNotes: event.adminNotes,
        );
        emit(PaymentVerificationActionSuccess(
            event.isApproved ? 'Pembayaran berhasil disetujui.' : 'Pembayaran berhasil ditolak.'
        ));
        add(FetchPendingPayments()); 
      } catch (e) {
        emit(PaymentVerificationError(e.toString()));
      }
    });

    on<RefundPaymentEvent>((event, emit) async {
      emit(PaymentVerificationLoading());
      try {
        await refundPaymentUseCase.call(
          event.paymentId, 
          event.reason,
        );
        emit(PaymentVerificationActionSuccess('Dana pembayaran berhasil di-refund.'));
        add(FetchPendingPayments()); 
      } catch (e) {
        emit(PaymentVerificationError(e.toString()));
      }
    });
  }
}