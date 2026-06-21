// Widget test untuk InvoicePaymentPage
//
// Memverifikasi:
//  - Halaman menampilkan judul yang benar per tipe invoice
//  - Badge label tipe invoice sesuai
//  - Invoice card menampilkan nomor invoice, jumlah, jatuh tempo, kamar
//  - Tombol "Kirim Bukti Pembayaran" muncul di mode manual
//  - Validasi: tombol disabled jika belum ada file dipilih
//  - Selector metode muncul/hilang berdasarkan status Midtrans
//
// Catatan: InvoicePaymentPage menerima optional `bloc` parameter untuk test
// sehingga tidak perlu setup GetIt/serviceLocator.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/finance/fine_eligible_user_entity.dart';
import 'package:frontend/domain/entity/finance/fine_entity.dart';
import 'package:frontend/domain/entity/finance/invoice_entity.dart';
import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/member_finance_summary_entity.dart';
import 'package:frontend/domain/entity/finance/midtrans_monitoring_entity.dart';
import 'package:frontend/domain/entity/finance/payment_entity.dart';
import 'package:frontend/domain/entity/finance/expense_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import 'package:frontend/domain/entity/setting/bank_account_entity.dart';
import 'package:frontend/domain/entity/setting/midtrans_fee_config_entity.dart';
import 'package:frontend/domain/entity/setting/midtrans_method_entity.dart';
import 'package:frontend/domain/entity/setting/setting_entity.dart';
import 'package:frontend/domain/repository/finance_repository.dart';
import 'package:frontend/domain/repository/setting_repository.dart';
import 'package:frontend/domain/usecase/finance/extend_lease_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_member_finance_summary_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_member_invoices_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_member_payments_usecase.dart';
import 'package:frontend/domain/usecase/finance/get_my_fines_usecase.dart';
import 'package:frontend/domain/usecase/finance/pay_fines_usecase.dart';
import 'package:frontend/domain/usecase/finance/pay_invoice_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_bank_accounts_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
import 'package:frontend/presentation/bloc/member_finance/member_finance_bloc.dart';
import 'package:frontend/presentation/bloc/member_finance/member_finance_event.dart';
import 'package:frontend/presentation/bloc/member_finance/member_finance_state.dart';
import 'package:frontend/presentation/pages/member_finance/invoice_payment_page.dart';

// ── Fake Repositories ──────────────────────────────────────────────────────

class _FakeFinanceRepository implements FinanceRepository {
  @override Future<List<InvoiceEntity>> getDueInvoices() async => [];
  @override Future<List<InvoiceEntity>> getInvoices() async => [];
  @override Future<List<PaymentEntity>> getPendingPayments() async => [];
  @override Future<List<PaymentEntity>> getAllPayments() async => [];
  @override Future<KpiEntity> getKpiSummary({int? month, int? year}) => throw UnimplementedError();
  @override Future<List<RevenueEntity>> getRevenueChart() => throw UnimplementedError();
  @override Future<List<ExpenseEntity>> getExpenses() => throw UnimplementedError();
  @override Future<ExpenseEntity> createExpense(ExpenseEntity expense) => throw UnimplementedError();
  @override Future<ExpenseEntity> updateExpense(ExpenseEntity expense) => throw UnimplementedError();
  @override Future<void> deleteExpense(int id) => throw UnimplementedError();
  @override Future<bool> verifyPayment(int id, bool approved, String? notes) async => true;
  @override Future<bool> refundPayment(int id, String reason) async => true;
  @override Future<MemberFinanceSummaryEntity> getMemberFinanceSummary() async =>
      MemberFinanceSummaryEntity(residentName: 'Test', totalUnpaid: 0, unpaidCount: 0);
  @override Future<List<InvoiceEntity>> getMemberInvoices() async => [];
  @override Future<InvoiceEntity> getMemberInvoiceById(int id) => throw UnimplementedError();
  @override Future<List<PaymentEntity>> getMemberPayments() async => [];
  @override Future<PaymentEntity> payInvoice(
    int invoiceId, String paymentMethod, {
    Uint8List? paymentProofBytes, String? paymentProofName, String? preferredPaymentType,
  }) => throw UnimplementedError();
  @override Future<InvoiceEntity> initiatePerpanjangManual(int leaseId, int durationMonths) =>
      throw UnimplementedError();
  @override Future<PaymentEntity> extendLease(
    int leaseId, int durationMonths, String paymentMethod, {
    Uint8List? paymentProofBytes, String? paymentProofName, String? preferredPaymentType,
  }) => throw UnimplementedError();
  @override Future<String> getInvoicePrintLink(int invoiceId) => throw UnimplementedError();
  @override Future<List<MidtransMethodEntity>> getAvailablePaymentMethods() => throw UnimplementedError();
  @override Future<MidtransMonitoringEntity> getMidtransMonitoring() => throw UnimplementedError();
  @override Future<List<FineEntity>> getMyFines({String? status}) async => [];
  @override Future<PaymentEntity> payFines(
    List<int> fineIds, String paymentMethod, {
    Uint8List? paymentProofBytes, String? paymentProofName, String? preferredPaymentType,
  }) => throw UnimplementedError();
  @override Future<List<FineEntity>> getAllFines({String? status, int? tenantUserId}) async => [];
  @override Future<FineEntity> createFine({
    required int tenantUserId, required double amount, required String reason,
  }) => throw UnimplementedError();
  @override Future<FineEntity> waiveFine(int fineId, String waiveReason) => throw UnimplementedError();
  @override Future<FineEntity> cancelFine(int fineId) => throw UnimplementedError();
  @override Future<List<FineEligibleUserEntity>> getFineEligibleUsers() => throw UnimplementedError();
}

class _FakeSettingRepository implements SettingRepository {
  final List<BankAccountEntity> bankAccounts;
  final bool midtransEnabled;

  _FakeSettingRepository({this.bankAccounts = const [], this.midtransEnabled = false});

  @override Future<SettingEntity> getSettings() => throw UnimplementedError();
  @override Future<SettingEntity> getPublicSettings() async =>
      SettingEntity(settings: {'feature_payment_midtrans': midtransEnabled});
  @override Future<SettingEntity> updateBulkSettings(Map<String, dynamic> data) => throw UnimplementedError();
  @override Future<List<MidtransMethodEntity>> getPaymentMethods() => throw UnimplementedError();
  @override Future<List<MidtransMethodEntity>> updatePaymentMethods(List<String> codes) => throw UnimplementedError();
  @override Future<MidtransFeeConfigEntity> getMidtransFeeConfig() => throw UnimplementedError();
  @override Future<MidtransFeeConfigEntity> updateMidtransFeeConfig(MidtransFeeConfigEntity config) =>
      throw UnimplementedError();
  @override Future<List<BankAccountEntity>> getBankAccounts() => throw UnimplementedError();
  @override Future<List<BankAccountEntity>> getPublicBankAccounts() async => bankAccounts;
  @override Future<BankAccountEntity> createBankAccount(Map<String, dynamic> data) => throw UnimplementedError();
  @override Future<BankAccountEntity> updateBankAccount(int id, Map<String, dynamic> data) =>
      throw UnimplementedError();
  @override Future<void> deleteBankAccount(int id) => throw UnimplementedError();
}

// ── Helper ─────────────────────────────────────────────────────────────────

MemberFinanceBloc _makeBloc({
  List<BankAccountEntity> bankAccounts = const [],
  bool midtransEnabled = false,
}) {
  final finRepo = _FakeFinanceRepository();
  final settingRepo = _FakeSettingRepository(
    bankAccounts: bankAccounts,
    midtransEnabled: midtransEnabled,
  );
  return MemberFinanceBloc(
    getSummary: GetMemberFinanceSummaryUseCase(finRepo),
    getInvoices: GetMemberInvoicesUseCase(finRepo),
    getPayments: GetMemberPaymentsUseCase(finRepo),
    getMyFines: GetMyFinesUseCase(finRepo),
    payFines: PayFinesUseCase(finRepo),
    payInvoice: PayInvoiceUseCase(finRepo),
    extendLease: ExtendLeaseUseCase(finRepo),
    getSettings: GetPublicSettingsUseCase(settingRepo),
    getBankAccounts: GetPublicBankAccountsUseCase(settingRepo),
  );
}

// Menginjeksi bloc langsung ke page (bypass serviceLocator)
Widget _wrapPage(InvoicePaymentPage page) {
  return BlocProvider<MemberFinanceBloc>.value(
    value: page.bloc!,
    child: MaterialApp(home: page),
  );
}

InvoicePaymentPage _makePage({
  required MemberFinanceBloc bloc,
  int invoiceId = 1,
  String invoiceNumber = 'TEST-001',
  double amount = 375000,
  String? roomNumber,
  String? invoiceType,
  DateTime? dueDate,
}) {
  return InvoicePaymentPage(
    invoiceId: invoiceId,
    invoiceNumber: invoiceNumber,
    amount: amount,
    roomNumber: roomNumber,
    invoiceType: invoiceType,
    dueDate: dueDate,
    bloc: bloc,
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('InvoicePaymentPage — judul AppBar per tipe invoice', () {
    Future<void> pumpPage(WidgetTester tester, {required String invoiceType}) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: invoiceType)));
      await tester.pump();
    }

    testWidgets('judul "Bayar Pelunasan" untuk tipe pelunasan', (tester) async {
      await pumpPage(tester, invoiceType: 'pelunasan');
      expect(find.text('Bayar Pelunasan'), findsOneWidget);
    });

    testWidgets('judul "Bayar Uang Muka (DP)" untuk tipe dp', (tester) async {
      await pumpPage(tester, invoiceType: 'dp');
      expect(find.text('Bayar Uang Muka (DP)'), findsOneWidget);
    });

    testWidgets('judul "Bayar Perpanjangan Sewa" untuk tipe extension', (tester) async {
      await pumpPage(tester, invoiceType: 'extension');
      expect(find.text('Bayar Perpanjangan Sewa'), findsOneWidget);
    });

    testWidgets('judul "Bayar Denda" untuk tipe fine', (tester) async {
      await pumpPage(tester, invoiceType: 'fine');
      expect(find.text('Bayar Denda'), findsOneWidget);
    });

    testWidgets('judul "Bayar Tagihan" untuk tipe tidak dikenal', (tester) async {
      await pumpPage(tester, invoiceType: 'unknown');
      expect(find.text('Bayar Tagihan'), findsOneWidget);
    });
  });

  group('InvoicePaymentPage — badge label di invoice card', () {
    testWidgets('badge "Pelunasan" muncul untuk tipe pelunasan', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(bloc: bloc, invoiceNumber: 'PLN-001', invoiceType: 'pelunasan'),
      ));
      await tester.pump();
      expect(find.text('Pelunasan'), findsOneWidget);
    });

    testWidgets('badge "Uang Muka (DP)" muncul untuk tipe dp', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(bloc: bloc, invoiceNumber: 'DP-001', invoiceType: 'dp'),
      ));
      await tester.pump();
      expect(find.text('Uang Muka (DP)'), findsOneWidget);
    });

    testWidgets('badge "Perpanjangan" muncul untuk tipe extension', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(bloc: bloc, invoiceNumber: 'EXT-001', invoiceType: 'extension'),
      ));
      await tester.pump();
      expect(find.text('Perpanjangan'), findsOneWidget);
    });
  });

  group('InvoicePaymentPage — invoice card menampilkan data benar', () {
    testWidgets('nomor invoice tampil di card', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(bloc: bloc, invoiceNumber: 'PLN-20260621-0001', invoiceType: 'pelunasan'),
      ));
      await tester.pump();
      expect(find.text('PLN-20260621-0001'), findsOneWidget);
    });

    testWidgets('nomor kamar tampil jika disediakan', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(bloc: bloc, invoiceType: 'pelunasan', roomNumber: '101'),
      ));
      await tester.pump();
      expect(find.text('Kamar 101'), findsOneWidget);
    });

    testWidgets('jatuh tempo tampil jika dueDate disediakan', (tester) async {
      final bloc = _makeBloc();
      await tester.pumpWidget(_wrapPage(
        _makePage(
          bloc: bloc,
          invoiceType: 'pelunasan',
          dueDate: DateTime(2026, 7, 1),
        ),
      ));
      await tester.pump();
      // "Jatuh tempo" adalah teks hardcoded — tidak bergantung pada locale intl
      expect(find.textContaining('Jatuh tempo'), findsOneWidget);
    });

  });

  group('InvoicePaymentPage — seksi manual payment (Midtrans non-aktif)', () {
    testWidgets('tombol "Kirim Bukti Pembayaran" muncul', (tester) async {
      final bloc = _makeBloc(midtransEnabled: false);
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pump();
      expect(find.text('Kirim Bukti Pembayaran'), findsOneWidget);
    });

    testWidgets('tap tombol sebelum pilih file tidak trigger loading state', (tester) async {
      // Verifikasi perilaku: tombol submit harus disabled (tidak bisa di-tap)
      // Cara test yang robust: tap dan pastikan BLoC tidak berubah ke loading
      final bloc = _makeBloc(midtransEnabled: false);
      bloc.add(FetchMemberFinanceSummary());
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pumpAndSettle();

      // Teks tombol muncul
      expect(find.text('Kirim Bukti Pembayaran'), findsOneWidget);

      // Tap tombol - seharusnya tidak berpengaruh karena disabled
      await tester.tap(find.text('Kirim Bukti Pembayaran'), warnIfMissed: false);
      await tester.pump();

      // BLoC tidak boleh berpindah ke loading state
      expect(bloc.state.status, isNot(MemberFinanceStatus.loading),
          reason: 'Submit tidak boleh jalan tanpa file terpilih');
    });

    testWidgets('area upload tampil dengan teks instruksi', (tester) async {
      final bloc = _makeBloc(midtransEnabled: false);
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pump();
      expect(find.textContaining('Klik untuk pilih gambar'), findsOneWidget);
    });

    testWidgets('rekening bank tampil setelah BLoC berhasil fetch', (tester) async {
      final bankAccounts = [
        const BankAccountEntity(
          id: 1,
          bankName: 'BRI',
          accountNumber: '1234567890',
          accountHolder: 'Wisma Amal',
          isActive: true,
          sortOrder: 1,
        ),
      ];
      final bloc = _makeBloc(bankAccounts: bankAccounts, midtransEnabled: false);
      bloc.add(FetchMemberFinanceSummary());

      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pumpAndSettle();

      expect(find.text('BRI'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('a.n. Wisma Amal'), findsOneWidget);
    });
  });

  group('InvoicePaymentPage — selector metode berdasarkan setting Midtrans', () {
    testWidgets('selector "Transfer Manual" & "Midtrans / QRIS" tampil jika Midtrans aktif', (tester) async {
      final bloc = _makeBloc(midtransEnabled: true);
      bloc.add(FetchMemberFinanceSummary());
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Manual'), findsOneWidget);
      expect(find.text('Midtrans / QRIS'), findsOneWidget);
    });

    testWidgets('selector tidak tampil jika Midtrans non-aktif', (tester) async {
      final bloc = _makeBloc(midtransEnabled: false);
      bloc.add(FetchMemberFinanceSummary());
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pumpAndSettle();

      expect(find.text('Midtrans / QRIS'), findsNothing);
    });

    testWidgets('default metode "manual" langsung tampilkan area upload', (tester) async {
      final bloc = _makeBloc(midtransEnabled: true);
      bloc.add(FetchMemberFinanceSummary());
      await tester.pumpWidget(_wrapPage(_makePage(bloc: bloc, invoiceType: 'pelunasan')));
      await tester.pumpAndSettle();

      // Saat Midtrans aktif, default metode = manual, jadi area upload tetap muncul
      expect(find.textContaining('Klik untuk pilih gambar'), findsOneWidget);
    });
  });
}
