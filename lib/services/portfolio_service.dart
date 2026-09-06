import '../models/portfolio_model.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import 'user_manager.dart';

/// مدیریت گردش‌کار نمونه‌کار هنرجو:
/// هنرجو ثبت می‌کند -> مدرس نمره و بازخورد می‌دهد -> مدیر تأیید یا نمره جایگزین ثبت می‌کند.
class PortfolioService {
  static final List<PortfolioModel> items = [];
  static const _key = 'erfan_oxygen_portfolio_v1';

  static Future<void> initialize() async {
    final raw = await StorageService.loadGenericList(_key);
    items
      ..clear()
      ..addAll(raw.map(PortfolioModel.fromJson));
  }

  static Future<void> _save() => StorageService.saveGenericList(_key, items.map((e) => e.toJson()).toList());

  static List<PortfolioModel> forStudent(String phone) =>
      items.where((e) => e.studentPhone == phone).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static List<PortfolioModel> pendingForTeacher() =>
      items.where((e) => e.status == PortfolioStatus.pendingTeacher).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  static List<PortfolioModel> reviewedByTeacher() => items
      .where((e) => e.status != PortfolioStatus.pendingTeacher && e.status != PortfolioStatus.draft)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static List<PortfolioModel> pendingForManager() =>
      items.where((e) => e.status == PortfolioStatus.pendingManager).toList()
        ..sort((a, b) => (a.teacherReviewedAt ?? a.createdAt).compareTo(b.teacherReviewedAt ?? b.createdAt));

  static List<PortfolioModel> decidedByManager() => items.where((e) => e.status == PortfolioStatus.approved).toList()
    ..sort((a, b) => (b.managerDecisionAt ?? b.createdAt).compareTo(a.managerDecisionAt ?? a.createdAt));

  /// STEP 1: هنرجو نمونه‌کار ثبت می‌کند.
  static Future<PortfolioModel> submit({
    required String studentPhone,
    required String studentName,
    required String title,
    required String description,
    required String imagePath,
    String? courseId,
  }) async {
    final item = PortfolioModel(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      studentPhone: studentPhone,
      studentName: studentName,
      title: title,
      description: description,
      imagePath: imagePath,
      courseId: courseId,
      status: PortfolioStatus.pendingTeacher,
    );
    items.add(item);
    await _save();

    final teacherPhones = UserManager.users.where((u) => u.role == 'teacher' && u.active).map((u) => u.phone).toList();
    if (teacherPhones.isNotEmpty) {
      await NotificationService.broadcast(
        phones: teacherPhones,
        title: 'نمونه‌کار جدید',
        body: '$studentName نمونه‌کار «$title» را برای بررسی ارسال کرد.',
        type: 'portfolio_submitted',
        relatedId: item.id,
      );
    }
    return item;
  }

  /// STEP 2: مدرس نمره و بازخورد ثبت می‌کند و برای مدیر ارسال می‌کند.
  static Future<void> teacherReview({
    required String id,
    required double score,
    required String feedback,
    required String teacherPhone,
  }) async {
    final item = _find(id);
    if (item == null) return;

    item
      ..teacherScore = score.clamp(0, 20).toDouble()
      ..teacherFeedback = feedback.trim()
      ..teacherPhone = teacherPhone
      ..teacherReviewedAt = DateTime.now()
      ..status = PortfolioStatus.pendingManager;
    await _save();

    final managerPhones = UserManager.users.where((u) => u.role == 'admin' && u.active).map((u) => u.phone).toList();
    if (managerPhones.isNotEmpty) {
      await NotificationService.broadcast(
        phones: managerPhones,
        title: 'نمونه‌کار در انتظار تأیید',
        body: 'مدرس برای نمونه‌کار «${item.title}» نمره ${item.teacherScore?.toStringAsFixed(1)} ثبت کرد.',
        type: 'portfolio_pending_manager',
        relatedId: item.id,
      );
    }
    await NotificationService.add(
      targetPhone: item.studentPhone,
      title: 'نمونه‌کار شما بررسی شد',
      body: 'مدرس نمونه‌کار «${item.title}» را بررسی کرد. در انتظار تأیید نهایی مدیر است.',
      type: 'portfolio_teacher_reviewed',
      relatedId: item.id,
    );
  }

  /// مدرس می‌تواند نمونه‌کار را رد کرده و به هنرجو بازگرداند.
  static Future<void> teacherReject({
    required String id,
    required String feedback,
    required String teacherPhone,
  }) async {
    final item = _find(id);
    if (item == null) return;

    item
      ..teacherFeedback = feedback.trim()
      ..teacherPhone = teacherPhone
      ..teacherReviewedAt = DateTime.now()
      ..status = PortfolioStatus.rejected;
    await _save();

    await NotificationService.add(
      targetPhone: item.studentPhone,
      title: 'نمونه‌کار رد شد',
      body: 'نمونه‌کار «${item.title}» توسط مدرس رد شد. دلیل: ${feedback.trim()}',
      type: 'portfolio_rejected',
      relatedId: item.id,
    );
  }

  /// STEP 3: مدیر یا نمره مدرس را می‌پذیرد یا نمره جایگزین ثبت می‌کند.
  static Future<void> managerDecide({
    required String id,
    required bool acceptTeacherScore,
    double? managerScore,
    String? managerFeedback,
    required String managerPhone,
  }) async {
    final item = _find(id);
    if (item == null) return;

    item
      ..managerAcceptedTeacherScore = acceptTeacherScore
      ..managerScore = acceptTeacherScore ? null : managerScore?.clamp(0, 20).toDouble()
      ..managerFeedback = (managerFeedback ?? '').trim().isEmpty ? null : managerFeedback!.trim()
      ..managerPhone = managerPhone
      ..managerDecisionAt = DateTime.now()
      ..status = PortfolioStatus.approved;
    await _save();

    await NotificationService.add(
      targetPhone: item.studentPhone,
      title: 'نمره نهایی نمونه‌کار شما ثبت شد',
      body: 'نمره نهایی «${item.title}»: ${item.finalScore?.toStringAsFixed(1)} از ۲۰',
      type: 'portfolio_approved',
      relatedId: item.id,
    );
  }

  static PortfolioModel? _find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static String statusLabel(String status) => switch (status) {
        PortfolioStatus.draft => 'پیش‌نویس',
        PortfolioStatus.pendingTeacher => 'در انتظار بررسی مدرس',
        PortfolioStatus.teacherReviewed => 'بررسی‌شده توسط مدرس',
        PortfolioStatus.pendingManager => 'در انتظار تأیید مدیر',
        PortfolioStatus.approved => 'تأیید نهایی',
        PortfolioStatus.rejected => 'رد شده',
        _ => status,
      };
}
