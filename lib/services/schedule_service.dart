import '../models/schedule_model.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'user_manager.dart';

class ScheduleService {
  static const _key = 'oxygen_schedule_v2';
  static final List<ScheduleItem> items = [];

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    items
      ..clear()
      ..addAll(raw.map(ScheduleItem.fromJson));
    if (items.isEmpty) {
      items.addAll([
        ScheduleItem(id: 'sch-1', day: 'شنبه', title: 'آرایش و پیرایش', time: '17:00', room: 'استودیو ۱'),
        ScheduleItem(id: 'sch-2', day: 'یکشنبه', title: 'رنگ و مش', time: '18:30', room: 'Color Lab'),
        ScheduleItem(id: 'sch-3', day: 'سه‌شنبه', title: 'تمرین عملی', time: '17:30', room: 'استودیو ۲'),
        ScheduleItem(id: 'sch-4', day: 'پنجشنبه', title: 'جلسه رفع اشکال', time: '19:00', room: 'کلاس اصلی'),
      ]);
      await save();
    }
  }

  static Future<void> save() => StorageService.saveGenericList(_key, items.map((e) => e.toJson()).toList());

  static Future<void> upsert(ScheduleItem item) async {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await save();
    final phones = UserManager.users.where((u) => u.active && u.role != 'admin').map((u) => u.phone).toList();
    await NotificationService.broadcast(
      phones: phones,
      title: 'برنامه کلاس‌ها تغییر کرد',
      body: '${item.day} • ${item.title} • ${item.time}',
      type: 'schedule_update',
      relatedId: item.id,
    );
  }

  static Future<void> remove(String id) async {
    items.removeWhere((e) => e.id == id);
    await save();
    final phones = UserManager.users.where((u) => u.active && u.role != 'admin').map((u) => u.phone).toList();
    await NotificationService.broadcast(
      phones: phones,
      title: 'یک برنامه کلاس حذف شد',
      body: 'برنامه کلاس‌ها توسط مدیر به‌روزرسانی شد.',
      type: 'schedule_update',
      relatedId: id,
    );
  }
}
