import 'package:flutter/material.dart';

import '../../services/current_user.dart';
import '../../services/customer_service.dart';
import '../../services/portfolio_service.dart';
import '../../models/portfolio_model.dart';
import '../../services/schedule_service.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.user;
    final role = switch (user?.role) {
      'admin' => 'مدیر سیستم',
      'teacher' => 'مدرس',
      'student' => 'هنرجو',
      _ => 'کاربر',
    };

    final stats = _statsFor(user?.role, user?.phone ?? '');

    return OxygenPage(
      title: 'پروفایل من',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: AppTheme.goldGlow(radius: 26),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: AppTheme.gold, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'کاربر',
                        style: const TextStyle(color: Colors.black, fontSize: 21, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(role, style: const TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatBox(label: stats.$1.$1, value: stats.$1.$2)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: stats.$2.$1, value: stats.$2.$2)),
              const SizedBox(width: 10),
              Expanded(child: _StatBox(label: stats.$3.$1, value: stats.$3.$2)),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'مدال‌ها'),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _Medal(icon: Icons.workspace_premium_rounded, label: 'عضو فعال')),
              SizedBox(width: 10),
              Expanded(child: _Medal(icon: Icons.star_rounded, label: 'کیفیت بالا')),
              SizedBox(width: 10),
              Expanded(child: _Medal(icon: Icons.verified_rounded, label: 'قابل اعتماد')),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'دستاوردهای من'),
          const SizedBox(height: 12),
          const _SatisfactionCard(),
          const SizedBox(height: 22),
          const SectionTitle(title: 'اطلاعات حساب'),
          const SizedBox(height: 12),
          _info(Icons.phone, 'شماره موبایل', user?.phone ?? '-'),
          if ((user?.specialty ?? '').isNotEmpty) _info(Icons.content_cut, 'تخصص', user!.specialty!),
          if ((user?.course ?? '').isNotEmpty) _info(Icons.school, 'دوره', user!.course!),
          if ((user?.fatherPhone ?? '').isNotEmpty) _info(Icons.family_restroom_rounded, 'شماره پدر/ولی', user!.fatherPhone!),
          if ((user?.nationalId ?? '').isNotEmpty) _info(Icons.badge_rounded, 'کد ملی', user!.nationalId!),
          _info(Icons.verified_user, 'وضعیت', user?.active == true ? 'فعال' : 'غیرفعال'),
        ],
      ),
    );
  }

  /// سه آمار مناسب نقش کاربر — همه از داده واقعی سرویس‌ها، بدون عدد ثابت.
  ((String, String), (String, String), (String, String)) _statsFor(String? role, String phone) {
    switch (role) {
      case 'admin':
        return (
          ('کلاس‌ها', '${ScheduleService.items.length}'),
          ('نمونه‌کار تأییدشده', '${PortfolioService.decidedByManager().length}'),
          ('مشتریان', '${CustomerService.customers.length}'),
        );
      case 'teacher':
        final reviewed = PortfolioService.reviewedByTeacher().where((e) => e.teacherPhone == phone).length;
        return (
          ('کلاس‌ها', '${ScheduleService.items.length}'),
          ('نمونه‌کار بررسی‌شده', '$reviewed'),
          ('هنرجوها', '${UserManager.users.where((u) => u.role == 'student').length}'),
        );
      case 'student':
        final mine = PortfolioService.forStudent(phone);
        final approved = mine.where((e) => e.status == PortfolioStatus.approved).length;
        return (
          ('نمونه‌کارهای من', '${mine.length}'),
          ('تأییدشده', '$approved'),
          ('در انتظار', '${mine.length - approved}'),
        );
      default:
        return (('—', '-'), ('—', '-'), ('—', '-'));
    }
  }

  Widget _info(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glass(radius: 18),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Icon(icon, color: AppTheme.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: AppTheme.glass(radius: 18, strong: true),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.gold)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 9.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Medal extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Medal({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: AppTheme.glass(radius: 18),
      child: Column(
        children: [
          Container(width: 40, height: 40, decoration: AppTheme.goldGlow(radius: 20), child: Icon(icon, color: Colors.black, size: 20)),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _SatisfactionCard extends StatelessWidget {
  const _SatisfactionCard();

  @override
  Widget build(BuildContext context) {
    const value = .85;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glass(radius: 20, strong: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('رضایت مشتریان', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              Text('۸۵٪', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
            ),
          ),
        ],
      ),
    );
  }
}
