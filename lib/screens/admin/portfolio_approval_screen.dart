import 'package:flutter/material.dart';

import '../../models/portfolio_model.dart';
import '../../services/current_user.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';

/// «تأیید نمونه‌کارها» — مدیر نمره مدرس را می‌پذیرد یا نمره جایگزین ثبت می‌کند.
class PortfolioApprovalScreen extends StatefulWidget {
  const PortfolioApprovalScreen({super.key});

  @override
  State<PortfolioApprovalScreen> createState() => _PortfolioApprovalScreenState();
}

class _PortfolioApprovalScreenState extends State<PortfolioApprovalScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = PortfolioService.pendingForManager();
    final decided = PortfolioService.decidedByManager();

    return OxygenPage(
      title: 'تأیید نمونه‌کارها',
      child: Column(
        children: [
          TabBar(
            controller: _tab,
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppTheme.gold,
            tabs: [Tab(text: 'در انتظار تأیید (${pending.length})'), const Tab(text: 'تأییدشده')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                pending.isEmpty
                    ? const Center(child: Text('چیزی در صف تأیید نیست', style: TextStyle(color: AppTheme.muted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        itemCount: pending.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _ApprovalCard(item: pending[index], onDone: () => setState(() {})),
                      ),
                decided.isEmpty
                    ? const Center(child: Text('هنوز موردی تأیید نشده است', style: TextStyle(color: AppTheme.muted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        itemCount: decided.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _DecidedCard(item: decided[index]),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final PortfolioModel item;
  final VoidCallback onDone;
  const _ApprovalCard({required this.item, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 20, strong: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 64, height: 64, child: CourseImage(source: item.imagePath))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text('هنرجو: ${item.studentName}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.priority_high_rounded, color: AppTheme.gold),
            ],
          ),
          const SizedBox(height: 10),
          Text('نمره پیشنهادی مدرس: ${item.teacherScore?.toStringAsFixed(1)} از ۲۰', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900)),
          if ((item.teacherFeedback ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(item.teacherFeedback!, style: const TextStyle(color: AppTheme.muted, fontSize: 11.5, height: 1.4)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _accept(context),
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('تأیید نمره مدرس'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _override(context),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('نمره جایگزین'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأیید نمره مدرس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نمره نهایی: ${item.teacherScore?.toStringAsFixed(1)} از ۲۰', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'یادداشت مدیر (اختیاری)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأیید نهایی')),
        ],
      ),
    );
    if (ok == true) {
      await PortfolioService.managerDecide(
        id: item.id,
        acceptTeacherScore: true,
        managerFeedback: noteCtrl.text.trim(),
        managerPhone: CurrentUser.phone,
      );
      onDone();
    }
  }

  Future<void> _override(BuildContext context) async {
    final scoreCtrl = TextEditingController(text: item.teacherScore?.toString() ?? '');
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ثبت نمره جایگزین'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: scoreCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'نمره نهایی جایگزین (از ۲۰)')),
            const SizedBox(height: 10),
            TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'دلیل تغییر نمره')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت نمره جایگزین')),
        ],
      ),
    );
    final score = double.tryParse(scoreCtrl.text.trim());
    if (ok == true && score != null) {
      await PortfolioService.managerDecide(
        id: item.id,
        acceptTeacherScore: false,
        managerScore: score,
        managerFeedback: noteCtrl.text.trim(),
        managerPhone: CurrentUser.phone,
      );
      onDone();
    }
  }
}

class _DecidedCard extends StatelessWidget {
  final PortfolioModel item;
  const _DecidedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 20),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(width: 56, height: 56, child: CourseImage(source: item.imagePath))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 3),
                Text('هنرجو: ${item.studentName}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                Text(
                  item.managerAcceptedTeacherScore ? 'نمره مدرس تأیید شد' : 'نمره جایگزین ثبت شد',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Text('${item.finalScore?.toStringAsFixed(1)}/۲۰', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}
