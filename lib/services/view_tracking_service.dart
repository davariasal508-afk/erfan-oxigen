import '../models/view_event_model.dart';
import 'storage_service.dart';

class ViewTrackingService {
  static const _key = 'oxygen_view_events_v2';
  static final List<ViewEventModel> events = [];

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    events
      ..clear()
      ..addAll(raw.map(ViewEventModel.fromJson));
  }

  static Future<void> markViewed({
    required String type,
    required String itemId,
    required String viewerPhone,
    required String viewerName,
  }) async {
    final exists = events.any((event) => event.key == '$type|$itemId|$viewerPhone');
    if (exists) return;
    events.add(ViewEventModel(type: type, itemId: itemId, viewerPhone: viewerPhone, viewerName: viewerName));
    await StorageService.saveGenericList(_key, events.map((e) => e.toJson()).toList());
  }

  static List<ViewEventModel> viewers(String type, String itemId) => events
      .where((event) => event.type == type && event.itemId == itemId)
      .toList()
    ..sort((a, b) => a.viewedAt.compareTo(b.viewedAt));
}
