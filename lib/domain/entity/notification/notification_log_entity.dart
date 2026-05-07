class NotificationLogItem {
  final int id;
  final String message;
  final String createdAt;
  final String status;
  final String? channel;
  final String? recipient;

  const NotificationLogItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.status,
    this.channel,
    this.recipient,
  });

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
      status: json['status']?.toString() ??
          json['status_label']?.toString() ??
          json['state']?.toString() ??
          '-',
      channel: json['channel']?.toString() ??
          json['type']?.toString() ??
          json['provider']?.toString(),
      recipient: json['recipient']?.toString() ??
          json['to']?.toString() ??
          json['target']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _resolveMessage(Map<String, dynamic> json) {
    final raw = json['message'] ??
        json['title'] ??
        json['body'] ??
        json['content'] ??
        json['description'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString();
    }

    final penghuni = json['penghuni'] ??
        json['resident_name'] ??
        (json['resident'] is Map<String, dynamic>
            ? (json['resident'] as Map<String, dynamic>)['name']
            : null) ??
        json['resident'];
    final kamar = json['kamar'] ??
        json['room_number'] ??
        (json['room'] is Map<String, dynamic>
            ? (json['room'] as Map<String, dynamic>)['number']
            : null) ??
        json['room'];

    if (penghuni != null || kamar != null) {
      final penghuniLabel = penghuni?.toString() ?? '-';
      final kamarLabel = kamar?.toString() ?? '-';
      return 'Tamu oleh penghuni $penghuniLabel pada kamar $kamarLabel saat nya keluar';
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

  const NotificationLogResponse({
    required this.logs,
    required this.pagination,
  });

  factory NotificationLogResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> items = <dynamic>[];
    Map<String, dynamic> metaMap = <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      if (data['data'] is List<dynamic>) {
        items = data['data'] as List<dynamic>;
      } else if (data['logs'] is List<dynamic>) {
        items = data['logs'] as List<dynamic>;
      } else if (data['items'] is List<dynamic>) {
        items = data['items'] as List<dynamic>;
      } else if (data['records'] is List<dynamic>) {
        items = data['records'] as List<dynamic>;
      }

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
    );
  }
}
