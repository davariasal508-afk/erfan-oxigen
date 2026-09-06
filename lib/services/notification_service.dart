import '../models/notification_model.dart';
import 'storage_service.dart';

class NotificationService {
  static final List<NotificationModel> notifications = [];
  static const _key = 'oxygen_notifications_v2';

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    notifications
      ..clear()
      ..addAll(raw.map(NotificationModel.fromJson));
  }

  static List<NotificationModel> forUser(String phone) => notifications
      .where((n) => n.targetPhone == phone || n.targetPhone == '*')
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static int unreadCount(String phone) => forUser(phone).where((n) => !n.read).length;

  static Future<void> add({
    required String targetPhone,
    required String title,
    required String body,
    String type = 'general',
    String? relatedId,
  }) async {
    notifications.add(NotificationModel(
      id: '${DateTime.now().microsecondsSinceEpoch}_${notifications.length}',
      targetPhone: targetPhone,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    ));
    await _save();
  }

  static Future<void> broadcast({
    required List<String> phones,
    required String title,
    required String body,
    String type = 'general',
    String? relatedId,
  }) async {
    for (final phone in phones.toSet()) {
      notifications.add(NotificationModel(
        id: '${DateTime.now().microsecondsSinceEpoch}_${notifications.length}',
        targetPhone: phone,
        title: title,
        body: body,
        type: type,
        relatedId: relatedId,
      ));
    }
    await _save();
  }

  static Future<void> markRead(String id) async {
    final n = notifications.where((item) => item.id == id).firstOrNull;
    if (n == null) return;
    n.read = true;
    await _save();
  }

  static Future<void> markAllRead(String phone) async {
    for (final n in notifications.where((n) => n.targetPhone == phone || n.targetPhone == '*')) {
      n.read = true;
    }
    await _save();
  }

  static Future<void> _save() => StorageService.saveGenericList(_key, notifications.map((e) => e.toJson()).toList());
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
