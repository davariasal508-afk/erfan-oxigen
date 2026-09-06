import 'package:flutter/material.dart';

import '../../models/portfolio_model.dart';
import '../../services/current_user.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';

/// «گواهی‌ها» — برای هر نمونه‌کار تأییدشده (approved) یک گواهی واقعی صادر می‌شود.
class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isStudent = CurrentUser.user?.role == 'student';
    final items = isStudent
        ? PortfolioService.forStudent(CurrentUser.phone).where((e) => e.status == PortfolioStatus.approved).toList()
        : PortfolioService.decidedByManager();

    return OxygenPage(
      title: 'گواهی‌ها',
      child: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'هنوز گواهی‌ای صادر نشده است.\nبعد از تأیید نهایی نمونه‌کار، گواهی این‌جا نمایش داده می‌شود.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.muted, height: 1.6),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) => _CertificateCard(item: items[index]),
            ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final PortfolioModel item;
  const _CertificateCard({required this.item});

  String get _certificateId {
    final y = item.managerDecisionAt?.year ?? item.createdAt.year;
    final tail = item.id.length >= 4 ? item.id.substring(item.id.length - 4) : item.id;
    return 'OX-$y-$tail';
  }

  @override
  Widget build(BuildContext context) {
    final date = item.managerDecisionAt ?? item.createdAt;
    final dateStr = '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(colors: [AppTheme.gold2, AppTheme.gold, AppTheme.bronze]),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF171009), Color(0xFF0B0D11)],
          ),
        ),
        child: Column(
          children: [
            Image.asset('assets/images/oxigen_shield_mark.png', height: 70, filterQuality: FilterQuality.high),
            const SizedBox(height: 10),
            Text('ERFAN OXIGEN', style: brandWordmarkFont(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 2.4, color: AppTheme.gold)),
            const Text('HAIR • BEAUTY • ACADEMY', style: TextStyle(color: AppTheme.muted, fontSize: 8, letterSpacing: 2)),
            const SizedBox(height: 18),
            Container(height: 1, width: 60, color: AppTheme.gold.withValues(alpha: .4)),
            const SizedBox(height: 18),
            const Text('CERTIFICATE OF ACHIEVEMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.white70)),
            const SizedBox(height: 14),
            const Text('گواهی می‌شود که', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            const SizedBox(height: 8),
            Text(item.studentName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('برای نمونه‌کار «${item.title}» با نمره نهایی', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.6)),
            const SizedBox(height: 6),
            Text('${item.finalScore?.toStringAsFixed(1) ?? '-'} از ۲۰', style: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            Container(height: 1, width: 60, color: AppTheme.gold.withValues(alpha: .4)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تاریخ صدور', style: TextStyle(color: AppTheme.muted, fontSize: 9)),
                    Text(dateStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('کد گواهی', style: TextStyle(color: AppTheme.muted, fontSize: 9)),
                    Text(_certificateId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.gold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _notReady(context, 'دانلود PDF'),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('دانلود'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _notReady(context, 'اشتراک‌گذاری'),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text('اشتراک‌گذاری'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _notReady(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature در نسخه بعدی سرور فعال می‌شود.')),
    );
  }
}
