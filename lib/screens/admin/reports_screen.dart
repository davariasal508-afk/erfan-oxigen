import 'package:flutter/material.dart';

import '../../services/exam_service.dart';
import '../../services/portfolio_service.dart';
import '../../models/portfolio_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teachers = UserManager.getUsersByRole('teacher');
    final students = UserManager.getUsersByRole('student');
    final admins = UserManager.getUsersByRole('admin');
    final total = UserManager.users.length;
    final active = UserManager.users.where((u) => u.active).length;
    final exams = ExamService.exams.length;
    final graded = ExamService.exams.where((e) => e.score != null).length;

    return OxygenPage(
      title: 'گزارش‌ها',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SectionTitle(title: 'داشبورد آماری', subtitle: 'تصویر سریع از وضعیت آموزشگاه'),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _stat('کل کاربران', '$total', Icons.groups),
              _stat('کاربران فعال', '$active', Icons.verified_user),
              _stat('مدرس‌ها', '${teachers.length}', Icons.school),
              _stat('هنرجوها', '${students.length}', Icons.person),
              _stat('مدیرها', '${admins.length}', Icons.admin_panel_settings),
              _stat('آزمون‌ها', '$exams', Icons.assignment),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'وضعیت آزمون‌ها'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.glass(radius: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('آزمون‌های دارای نمره: $graded از $exams', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: exams == 0 ? 0 : graded / exams,
                    backgroundColor: Colors.white10,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(exams == 0 ? 'هنوز آزمونی ثبت نشده است.' : 'درصد تکمیل نمرات: ${(graded / exams * 100).round()}%', style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'وضعیت نمونه‌کارها'),
          const SizedBox(height: 12),
          _PortfolioBreakdown(items: PortfolioService.items),
          const SizedBox(height: 22),
          const SectionTitle(title: 'گزارش‌های سریع'),
          const SizedBox(height: 12),
          _report('گزارش مدرس‌ها', 'وضعیت فعال بودن و تعداد مدرس‌ها', Icons.school, 'مدرس فعال: ${teachers.where((u) => u.active).length}'),
          _report('گزارش هنرجوها', 'وضعیت ثبت‌نام و فعالیت هنرجوها', Icons.groups, 'هنرجوی فعال: ${students.where((u) => u.active).length}'),
          _report('گزارش نمرات', 'وضعیت آزمون‌ها و امتیازات', Icons.grade, 'آزمون دارای نمره: $graded'),
          _report('گزارش فعالیت', 'آخرین وضعیت کلی سیستم', Icons.insights, 'کل کاربران: $total'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glass(radius: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppTheme.gold), const Spacer(), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppTheme.muted))]),
    );
  }

  Widget _report(String title, String subtitle, IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glass(radius: 18),
      child: Row(children: [Container(width: 44, height: 44, decoration: AppTheme.goldGlow(radius: 14), child: Icon(icon, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: AppTheme.muted, fontSize: 12)), const SizedBox(height: 6), Text(value, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800))]))]),
    );
  }
}

class _PortfolioBreakdown extends StatelessWidget {
  final List<PortfolioModel> items;
  const _PortfolioBreakdown({required this.items});

  @override
  Widget build(BuildContext context) {
    final pendingTeacher = items.where((e) => e.status == PortfolioStatus.pendingTeacher).length;
    final pendingManager = items.where((e) => e.status == PortfolioStatus.pendingManager).length;
    final approved = items.where((e) => e.status == PortfolioStatus.approved).length;
    final rejected = items.where((e) => e.status == PortfolioStatus.rejected).length;
    final total = items.length;

    final slices = [
      _Slice('در انتظار مدرس', pendingTeacher, AppTheme.gold),
      _Slice('در انتظار مدیر', pendingManager, AppTheme.info),
      _Slice('تأییدشده', approved, AppTheme.success),
      _Slice('رد شده', rejected, AppTheme.danger),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glass(radius: 22, strong: true),
      child: total == 0
          ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('هنوز نمونه‌کاری ثبت نشده است.', style: TextStyle(color: AppTheme.muted))))
          : Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: CustomPaint(
                    painter: _DonutPainter(slices: slices, total: total),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                          const Text('کل', style: TextStyle(color: AppTheme.muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: slices
                        .where((s) => s.value > 0)
                        .map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Container(width: 9, height: 9, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(s.label, style: const TextStyle(fontSize: 11.5))),
                                  Text('${s.value}', style: TextStyle(color: s.color, fontWeight: FontWeight.w900, fontSize: 12)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Slice {
  final String label;
  final int value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_Slice> slices;
  final int total;
  const _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(6);
    double start = -90 * (3.1415926535 / 180);
    for (final slice in slices) {
      if (slice.value == 0) continue;
      final sweep = (slice.value / total) * 2 * 3.1415926535;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.slices != slices;
}
