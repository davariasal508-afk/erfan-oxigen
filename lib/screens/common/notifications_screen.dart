import 'package:flutter/material.dart';
import '../../services/current_user.dart';
import '../../services/customer_session_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../admin/booking_requests_screen.dart';
import '../admin/exams_screen.dart';
import '../admin/portfolio_approval_screen.dart';
import '../teacher/portfolio_review_screen.dart';
import 'booking_screen.dart';
import 'portfolio_screen.dart';
import 'schedule_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String get _myPhone => CustomerSessionService.customer?.phone ?? CurrentUser.phone;

  @override
  Widget build(BuildContext context) {
    final items = NotificationService.forUser(_myPhone);
    return OxygenPage(
      title: 'اعلان‌ها',
      actions: [IconButton(tooltip: 'همه خوانده شد', onPressed: () async { await NotificationService.markAllRead(_myPhone); if (mounted) setState(() {}); }, icon: const Icon(Icons.done_all_rounded))],
      child: items.isEmpty
          ? const Center(child: Text('اعلان جدیدی ندارید', style: TextStyle(color: AppTheme.muted)))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    await NotificationService.markRead(item.id);
                    if (!mounted) return;
                    if (item.type == 'grade_approval' && CurrentUser.role == 'admin') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const ExamsScreen()));
                    } else if (item.type == 'schedule_update') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const ScheduleScreen()));
                    } else if (item.type == 'portfolio_submitted' && CurrentUser.role == 'teacher') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const PortfolioReviewScreen()));
                    } else if (item.type == 'portfolio_pending_manager' && CurrentUser.role == 'admin') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const PortfolioApprovalScreen()));
                    } else if (item.type.startsWith('portfolio_') && CurrentUser.role == 'student') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const PortfolioScreen()));
                    } else if (item.type == 'booking_requested' && CurrentUser.role == 'admin') {
                      await navigator.push(MaterialPageRoute(builder: (_) => const BookingRequestsScreen()));
                    } else if (item.type.startsWith('booking_') && CustomerSessionService.customer != null) {
                      await navigator.push(MaterialPageRoute(builder: (_) => const BookingScreen()));
                    }
                    if (mounted) setState(() {});
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.glass(radius: 20, strong: !item.read),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 46, decoration: AppTheme.goldGlow(radius: 14), child: Icon(_icon(item.type), color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900))), if (!item.read) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle))]), const SizedBox(height: 5), Text(item.body, style: const TextStyle(color: AppTheme.muted, height: 1.45)), const SizedBox(height: 6), Text(_relative(item.createdAt), style: const TextStyle(color: Colors.white30, fontSize: 10))]))]),
                  ),
                );
              },
            ),
    );
  }

  IconData _icon(String type) => switch (type) {
        'grade_approval' => Icons.fact_check_rounded,
        'grade_published' => Icons.grade_rounded,
        'schedule_update' => Icons.calendar_month_rounded,
        'chat' => Icons.forum_rounded,
        'portfolio_submitted' => Icons.upload_file_rounded,
        'portfolio_pending_manager' => Icons.hourglass_top_rounded,
        'portfolio_teacher_reviewed' => Icons.rate_review_rounded,
        'portfolio_approved' => Icons.verified_rounded,
        'portfolio_rejected' => Icons.cancel_rounded,
        'booking_requested' => Icons.event_available_rounded,
        'booking_confirmed' => Icons.check_circle_rounded,
        'booking_cancelled' => Icons.event_busy_rounded,
        'booking_rescheduled' => Icons.schedule_rounded,
        _ => Icons.notifications_rounded,
      };

  String _relative(DateTime date) {
    final minutes = DateTime.now().difference(date).inMinutes;
    if (minutes < 1) return 'همین الان';
    if (minutes < 60) return '$minutes دقیقه پیش';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours ساعت پیش';
    return '${hours ~/ 24} روز پیش';
  }
}
