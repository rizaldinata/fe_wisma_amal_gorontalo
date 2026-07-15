import 'package:frontend/domain/entity/notification/notification_log_entity.dart';
import 'dart:convert';

void main() {
  final jsonStr = '''
  {
    "success": true,
    "data": {
      "current_page": 1,
      "data": [
        {
          "id": 1,
          "type": "guest_registered",
          "target_phone": "admin",
          "message_body": "Tamu pada kamar 101 akan menginap.",
          "status": "sent",
          "is_read": false,
          "created_at": "2023-10-27T10:00:00.000000Z"
        }
      ],
      "first_page_url": "http://localhost/api/notification/logs?page=1",
      "from": 1,
      "last_page": 1,
      "last_page_url": "http://localhost/api/notification/logs?page=1",
      "links": [],
      "next_page_url": null,
      "path": "http://localhost/api/notification/logs",
      "per_page": 15,
      "prev_page_url": null,
      "to": 1,
      "total": 1
    },
    "unread_count": 1
  }
  ''';

  final json = jsonDecode(jsonStr);
  final response = NotificationLogResponse.fromJson(json);

  print("Parsed items count: ${response.logs.length}");
  if (response.logs.isNotEmpty) {
    print("First item message: ${response.logs.first.message}");
    print("Unread count: ${response.unreadCount}");
  }
}
