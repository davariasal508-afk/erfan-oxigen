import '../models/booking_model.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'user_manager.dart';

/// نوبت واقعی مشتری: ثبت → اطلاع مدیر → تأیید/رد/تغییر زمان → اطلاع مشتری.
class BookingService {
  static final List<BookingModel> items = [];
  static const _key = 'erfan_oxygen_bookings_v1';

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    items
      ..clear()
      ..addAll(raw.map(BookingModel.fromJson));
  }

  static Future<void> _save() => StorageService.saveGenericList(_key, items.map((e) => e.toJson()).toList());

  static List<BookingModel> forCustomer(String phone) =>
      items.where((e) => e.customerPhone == phone).toList()..sort((a, b) => b.date.compareTo(a.date));

  static List<BookingModel> pendingForManager() => items.where((e) => e.status == BookingStatus.pending).toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  static List<BookingModel> upcomingConfirmed() =>
      items.where((e) => e.status == BookingStatus.confirmed && e.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  static BookingModel? nextForCustomer(String phone) {
    final upcoming = items
        .where((e) => e.customerPhone == phone && e.status == BookingStatus.confirmed && e.date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  static Future<BookingModel> submit({
    required String customerPhone,
    required String customerName,
    required String service,
    required DateTime date,
    required String time,
  }) async {
    final booking = BookingModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      customerPhone: customerPhone,
      customerName: customerName,
      service: service,
      date: date,
      time: time,
    );
    items.add(booking);
    await _save();

    final managerPhones = UserManager.users.where((u) => u.role == 'admin' && u.active).map((u) => u.phone).toList();
    if (managerPhones.isNotEmpty) {
      await NotificationService.broadcast(
        phones: managerPhones,
        title: 'درخواست نوبت جدید',
        body: '$customerName برای «$service» در ${_fmt(date)} ساعت $time درخواست نوبت داد.',
        type: 'booking_requested',
        relatedId: booking.id,
      );
    }
    return booking;
  }

  static Future<void> approve(String id, {String? note}) async {
    final booking = _find(id);
    if (booking == null) return;
    booking
      ..status = BookingStatus.confirmed
      ..managerNote = note
      ..decidedAt = DateTime.now();
    await _save();
    await NotificationService.add(
      targetPhone: booking.customerPhone,
      title: 'نوبت شما تأیید شد',
      body: '«${booking.service}» در ${_fmt(booking.date)} ساعت ${booking.time} تأیید شد.',
      type: 'booking_confirmed',
      relatedId: booking.id,
    );
  }

  static Future<void> cancel(String id, {String? reason}) async {
    final booking = _find(id);
    if (booking == null) return;
    booking
      ..status = BookingStatus.cancelled
      ..managerNote = reason
      ..decidedAt = DateTime.now();
    await _save();
    await NotificationService.add(
      targetPhone: booking.customerPhone,
      title: 'نوبت شما لغو شد',
      body: reason == null || reason.isEmpty ? '«${booking.service}» لغو شد.' : '«${booking.service}» لغو شد. دلیل: $reason',
      type: 'booking_cancelled',
      relatedId: booking.id,
    );
  }

  static Future<void> reschedule(String id, {required DateTime newDate, required String newTime}) async {
    final booking = _find(id);
    if (booking == null) return;
    booking
      ..date = newDate
      ..time = newTime
      ..status = BookingStatus.pending
      ..decidedAt = DateTime.now();
    await _save();
    await NotificationService.add(
      targetPhone: booking.customerPhone,
      title: 'زمان نوبت شما تغییر کرد',
      body: '«${booking.service}» به ${_fmt(newDate)} ساعت $newTime منتقل شد و در انتظار تأیید مجدد است.',
      type: 'booking_rescheduled',
      relatedId: booking.id,
    );
  }

  static BookingModel? _find(String id) {
    for (final b in items) {
      if (b.id == id) return b;
    }
    return null;
  }

  static String _fmt(DateTime d) => '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  static String statusLabel(String status) => switch (status) {
        BookingStatus.pending => 'در انتظار تأیید',
        BookingStatus.confirmed => 'تأییدشده',
        BookingStatus.cancelled => 'لغوشده',
        BookingStatus.completed => 'انجام‌شده',
        _ => status,
      };
}
