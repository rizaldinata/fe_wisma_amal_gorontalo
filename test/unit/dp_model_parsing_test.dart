// TC-07a & TC-07b: Unit tests untuk parsing model terkait fitur DP
//
// Mengapa test ini penting:
//   TC-07a — Backend mengembalikan dp_amount sebagai String ("375000.00") karena cast
//             decimal:2 di Laravel. Flutter sebelumnya crash dengan TypeError saat
//             mencoba cast String ke num. Fix: double.tryParse().toString()
//   TC-07b — PaymentResource tidak menyertakan invoice_type, sehingga admin tidak
//             bisa membedakan DP vs Sewa di halaman verifikasi. Fix: tambah invoice_type.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/model/finance/payment_model.dart';

void main() {
  group('TC-07a — dp_amount parsing dari API', () {
    // Kasus utama yang menyebabkan bug: Laravel decimal:2 → JSON String
    test('double.tryParse menangani dp_amount sebagai String dari PHP decimal:2', () {
      const raw = '375000.00'; // format asli dari PHP cast 'decimal:2'
      final parsed = double.tryParse(raw.toString());
      expect(parsed, isNotNull);
      expect(parsed, equals(375000.0));
    });

    test('double.tryParse menangani dp_amount sebagai num (defensive: jika backend fix jalan)', () {
      const raw = 375000.0; // jika backend sudah cast ke float
      final parsed = double.tryParse(raw.toString());
      expect(parsed, isNotNull);
      expect(parsed, equals(375000.0));
    });

    test('double.tryParse mengembalikan null untuk dp_amount null (null safe)', () {
      const dynamic raw = null;
      final parsed = raw != null ? double.tryParse(raw.toString()) : null;
      expect(parsed, isNull);
    });

    test('double.tryParse menangani dp_amount nol', () {
      const raw = '0.00';
      final parsed = double.tryParse(raw.toString());
      expect(parsed, isNotNull);
      expect(parsed, equals(0.0));
    });

    // Membuktikan WHY bug lama terjadi — ini seharusnya throw
    test('[DOKUMENTASI BUG LAMA] cast as num? terhadap String akan throw TypeError', () {
      const dynamic raw = '375000.00'; // String dari API
      expect(
        () => (raw as num?)?.toDouble(),
        throwsA(isA<TypeError>()),
        reason: 'Inilah root cause TC-07a: String tidak bisa di-cast langsung ke num?',
      );
    });
  });

  group('TC-07b — invoice_type di PaymentModel', () {
    PaymentModel makePayment(Map<String, dynamic> overrides) {
      final base = <String, dynamic>{
        'id': 1,
        'invoice_id': 10,
        'invoice_number': 'DP-20260621-0001',
        'payment_method': 'manual',
        'status': 'pending',
        'amount': 375000,
        'payment_date': '2026-06-21T00:00:00Z',
      };
      return PaymentModel.fromJson({...base, ...overrides});
    }

    test('fromJson menyertakan invoice_type dp', () {
      final model = makePayment({'invoice_type': 'dp'});
      expect(model.invoiceType, equals('dp'));
    });

    test('fromJson menyertakan invoice_type pelunasan', () {
      final model = makePayment({'invoice_type': 'pelunasan'});
      expect(model.invoiceType, equals('pelunasan'));
    });

    test('fromJson menyertakan invoice_type sewa', () {
      final model = makePayment({'invoice_type': 'sewa'});
      expect(model.invoiceType, equals('sewa'));
    });

    test('fromJson menyertakan invoice_type extension', () {
      final model = makePayment({'invoice_type': 'extension'});
      expect(model.invoiceType, equals('extension'));
    });

    test('fromJson menyertakan invoice_type fine', () {
      final model = makePayment({'invoice_type': 'fine'});
      expect(model.invoiceType, equals('fine'));
    });

    test('fromJson invoice_type null jika tidak ada di response (backward compat)', () {
      final model = makePayment({}); // tidak ada invoice_type
      expect(model.invoiceType, isNull);
    });

    test('fromJson invoice_number terbaca dengan benar', () {
      final model = makePayment({'invoice_type': 'dp'});
      expect(model.invoiceNumber, equals('DP-20260621-0001'));
    });

    test('amount terparsing sebagai double dari int JSON', () {
      final model = makePayment({'amount': 375000});
      expect(model.amount, equals(375000.0));
    });
  });

  group('PaymentModel — field lain tidak terpengaruh oleh perubahan DP', () {
    test('snapToken terbaca untuk alur Midtrans', () {
      final model = PaymentModel.fromJson({
        'id': 2,
        'invoice_id': 11,
        'payment_method': 'midtrans',
        'status': 'pending',
        'amount': 500000,
        'payment_date': '2026-06-21T00:00:00Z',
        'snap_token': 'snap-abc-123',
        'invoice_type': 'pelunasan',
      });
      expect(model.snapToken, equals('snap-abc-123'));
      expect(model.invoiceType, equals('pelunasan'));
    });

    test('paymentData di-parse dari Map JSON langsung', () {
      final model = PaymentModel.fromJson({
        'id': 3,
        'invoice_id': 12,
        'payment_method': 'midtrans',
        'status': 'paid',
        'amount': 300000,
        'payment_date': '2026-06-21T00:00:00Z',
        'payment_data': {'order_id': 'ORDER-123', 'status_code': '200'},
        'invoice_type': 'dp',
      });
      expect(model.paymentData, isNotNull);
      expect(model.paymentData!['order_id'], equals('ORDER-123'));
    });

    test('paymentData di-parse dari String JSON', () {
      final model = PaymentModel.fromJson({
        'id': 4,
        'invoice_id': 13,
        'payment_method': 'midtrans',
        'status': 'paid',
        'amount': 300000,
        'payment_date': '2026-06-21T00:00:00Z',
        'payment_data': '{"order_id":"ORDER-456","status_code":"200"}',
        'invoice_type': 'sewa',
      });
      expect(model.paymentData, isNotNull);
      expect(model.paymentData!['order_id'], equals('ORDER-456'));
    });
  });
}
