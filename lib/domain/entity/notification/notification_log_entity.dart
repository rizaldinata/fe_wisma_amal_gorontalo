class NotificationLogItem {
  final int id;
  final String message;
  final String createdAt;
  final String status;
  final bool isRead;
  final String? channel;
  final String? recipient;

  const NotificationLogItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.status,
    required this.isRead,
    this.channel,
    this.recipient,
  });

  String get typeLabel => _resolveTypeLabel(channel);

  static String _resolveTypeLabel(String? type) {
    switch (type) {
      case 'payment_receipt':
        return 'Pembayaran';
      case 'payment_reminder':
        return 'Tagihan';
      case 'manual_broadcast':
        return 'Broadcast';
      case 'system_alert':
        return 'Sistem';
      case 'guest_registered':
        return 'Tamu Masuk';
      case 'guest_stay_ended':
        return 'Tamu Keluar';
      default:
        return type ?? '-';
    }
  }

  factory NotificationLogItem.fromJson(Map<String, dynamic> json) {
    final message = _resolveMessage(json);
    return NotificationLogItem(
      id: _parseInt(json['id']),
      message: message,
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          json['sent_at']?.toString() ??
          json['sentAt']?.toString() ??
          '-',
      status: _resolveStatus(json['status']?.toString()),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      // 'type' dari backend (enum value: guest_registered, dll)
      channel: json['type']?.toString() ??
          json['channel']?.toString() ??
          json['provider']?.toString(),
      // 'target_phone' dari backend
      recipient: json['target_phone']?.toString() ??
          json['recipient']?.toString() ??
          json['to']?.toString() ??
          json['target']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _resolveStatus(String? raw) {
    switch (raw) {
      case 'sent':
        return 'Terkirim';
      case 'failed':
        return 'Gagal';
      case 'pending':
        return 'Pending';
      default:
        return raw ?? '-';
    }
  }

  static String _resolveMessage(Map<String, dynamic> json) {
    // 'message_body' adalah field utama dari backend NotificationLog model
    final raw = json['message_body'] ??
        json['message'] ??
        json['title'] ??
        json['body'] ??
        json['content'] ??
        json['description'];

    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString();
    }

    return '-';
  }
}

class NotificationLogPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotificationLogPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory NotificationLogPagination.fromJson(Map<String, dynamic> json) {
    return NotificationLogPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

class NotificationLogResponse {
  final List<NotificationLogItem> logs;
  final NotificationLogPagination pagination;
  /// Jumlah notifikasi yang belum dibaca (dari field 'unread_count' di root response)
  final int unreadCount;

  const NotificationLogResponse({
    required this.logs,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationLogResponse.fromJson(Map<String, dynamic> json) {
    // 'unread_count' ada di root response: { success, data: {...paginator...}, unread_count: N }
    final unreadCount = json['unread_count'] as int? ?? 0;

    final data = json['data'];
    List<dynamic> items = <dynamic>[];
    Map<String, dynamic> metaMap = <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      // Laravel paginator: data.data = array of items
      if (data['data'] is List<dynamic>) {
        items = data['data'] as List<dynamic>;
      } else if (data['logs'] is List<dynamic>) {
        items = data['logs'] as List<dynamic>;
      } else if (data['items'] is List<dynamic>) {
        items = data['items'] as List<dynamic>;
      } else if (data['records'] is List<dynamic>) {
        items = data['records'] as List<dynamic>;
      }

      // Pagination metadata ada langsung di data (Laravel paginator)
      if (data['meta'] is Map<String, dynamic>) {
        metaMap = Map<String, dynamic>.from(data['meta'] as Map);
      } else if (data['pagination'] is Map<String, dynamic>) {
        metaMap = Map<String, dynamic>.from(data['pagination'] as Map);
      } else if (data.containsKey('current_page')) {
        metaMap = data;
      }
    } else if (data is List<dynamic>) {
      items = data;
    }

    return NotificationLogResponse(
      logs: items
          .map((e) => NotificationLogItem.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList(),
      pagination: NotificationLogPagination.fromJson(metaMap),
      unreadCount: unreadCount,
    );
  }
}
