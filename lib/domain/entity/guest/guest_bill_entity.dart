import 'dart:typed_data';

// ─── Entity untuk tagihan tamu (resident view) ────────────────────────────────

class GuestBillItem {
  final int id;
  final String billNumber;
  final double amount;
  final String status;
  final String statusLabel;
  final String? paymentMethod;
  final String? paymentProofUrl;
  final String? snapToken;
  final String? adminNotes;
  final String? paidAt;

  const GuestBillItem({
    required this.id,
    required this.billNumber,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.paymentMethod,
    this.paymentProofUrl,
    this.snapToken,
    this.adminNotes,
    this.paidAt,
  });

  bool get canPay => status == 'unpaid' || status == 'rejected';
  bool get isPending => status == 'pending';
  bool get isDone => status == 'verified' || status == 'paid';

  factory GuestBillItem.fromJson(Map<String, dynamic> json) {
    return GuestBillItem(
      id: json['id'] as int? ?? 0,
      billNumber: json['bill_number'] as String? ?? '-',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unpaid',
      statusLabel: json['status_label'] as String? ?? '-',
      paymentMethod: json['payment_method'] as String?,
      paymentProofUrl: json['payment_proof_url'] as String?,
      snapToken: json['snap_token'] as String?,
      adminNotes: json['admin_notes'] as String?,
      paidAt: json['paid_at'] as String?,
    );
  }
}

// ─── Entity untuk tagihan tamu (admin view) ───────────────────────────────────

class AdminGuestBillItem {
  final int id;
  final String billNumber;
  final double amount;
  final String status;
  final String statusLabel;
  final String? paymentMethod;
  final String? paymentProofUrl;
  final String? adminNotes;
  final String? paidAt;
  final String? createdAt;
  final String guestName;
  final String guestCheckIn;
  final String guestCheckOut;
  final int guestTotalDays;
  final int guestBillableDays;
  final String penghuni;
  final String kamar;

  const AdminGuestBillItem({
    required this.id,
    required this.billNumber,
    required this.amount,
    required this.status,
    required this.statusLabel,
    this.paymentMethod,
    this.paymentProofUrl,
    this.adminNotes,
    this.paidAt,
    this.createdAt,
    required this.guestName,
    required this.guestCheckIn,
    required this.guestCheckOut,
    required this.guestTotalDays,
    required this.guestBillableDays,
    required this.penghuni,
    required this.kamar,
  });

  bool get canVerify => status == 'pending' && paymentMethod == 'manual';

  factory AdminGuestBillItem.fromJson(Map<String, dynamic> json) {
    final guest = json['guest'] as Map<String, dynamic>? ?? {};
    return AdminGuestBillItem(
      id: json['id'] as int? ?? 0,
      billNumber: json['bill_number'] as String? ?? '-',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'unpaid',
      statusLabel: json['status_label'] as String? ?? '-',
      paymentMethod: json['payment_method'] as String?,
      paymentProofUrl: json['payment_proof_url'] as String?,
      adminNotes: json['admin_notes'] as String?,
      paidAt: json['paid_at'] as String?,
      createdAt: json['created_at'] as String?,
      guestName: guest['name'] as String? ?? '-',
      guestCheckIn: guest['check_in_at'] as String? ?? '-',
      guestCheckOut: guest['check_out_at'] as String? ?? '-',
      guestTotalDays: guest['total_days'] as int? ?? 0,
      guestBillableDays: guest['billable_days'] as int? ?? 0,
      penghuni: json['penghuni'] as String? ?? '-',
      kamar: json['kamar'] as String? ?? '-',
    );
  }
}

// ─── Pagination & Response ────────────────────────────────────────────────────

class AdminGuestBillPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const AdminGuestBillPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory AdminGuestBillPagination.fromJson(Map<String, dynamic> json) {
    return AdminGuestBillPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

class AdminGuestBillResponse {
  final List<AdminGuestBillItem> bills;
  final AdminGuestBillPagination pagination;

  const AdminGuestBillResponse({
    required this.bills,
    required this.pagination,
  });

  factory AdminGuestBillResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? {};
    final items = outer['data'] as List<dynamic>? ?? [];
    final meta = outer['meta'] as Map<String, dynamic>? ?? {};
    return AdminGuestBillResponse(
      bills: items
          .map((e) => AdminGuestBillItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: AdminGuestBillPagination.fromJson(meta),
    );
  }
}

// ─── Payload untuk pembayaran ─────────────────────────────────────────────────

class PayGuestBillPayload {
  final int guestId;
  final String paymentMethod;
  final Uint8List? proofBytes;
  final String? proofName;

  const PayGuestBillPayload({
    required this.guestId,
    required this.paymentMethod,
    this.proofBytes,
    this.proofName,
  });
}
