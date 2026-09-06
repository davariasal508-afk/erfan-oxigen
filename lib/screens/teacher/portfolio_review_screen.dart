import 'package:flutter/material.dart';

import '../../models/portfolio_model.dart';
import '../../services/current_user.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';

/// «بررسی نمونه‌کارها» — مدرس نمونه‌کارهای هنرجویان را نمره و بازخورد می‌دهد.
class PortfolioReviewScreen extends StatefulWidget {
  const PortfolioReviewScreen({super.key});

  @override
  State<PortfolioReviewScreen> createState() => _PortfolioReviewScreenState();
}

class _PortfolioReviewScreenState extends State<PortfolioReviewScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = PortfolioService.pendingForTeacher();
    final reviewed = PortfolioService.reviewedByTeacher();

    return OxygenPage(
      title: 'بررسی نمونه‌کارها',
      child: Column(
        children: [
          TabBar(
            controller: _tab,
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppTheme.gold,
            tabs: [Tab(text: 'در انتظار بررسی (${pending.length})'), const Tab(text: 'بررسی‌شده')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _list(pending, showActions: true),
                _list(reviewed, showActions: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<PortfolioModel> items, {required bool showActions}) {
    if (items.isEmpty) {
      return const Center(child: Text('موردی وجود ندارد', style: TextStyle(color: AppTheme.muted)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _ReviewCard(item: items[index], showActions: showActions, onDone: () => setState(() {})),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final PortfolioModel item;
  final bool showActions;
  final VoidCallback onDone;
  const _ReviewCard({required this.item, required this.showActions, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 20, strong: showActions),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(width: 64, height: 64, child: CourseImage(source: item.imagePath)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(item.studentName, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.description, style: const TextStyle(color: AppTheme.muted, fontSize: 11.5, height: 1.4)),
          ],
          if (!showActions) ...[
            const SizedBox(height: 10),
            Text(
              PortfolioService.statusLabel(item.status),
              style: const TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w800),
            ),
            if (item.teacherScore != null)
              Text('نمره ثبت‌شده: ${item.teacherScore!.toStringAsFixed(1)} از ۲۰', style: const TextStyle(fontSize: 11.5)),
          ],
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _review(context),
                    icon: const Icon(Icons.rate_review_rounded),
                    label: const Text('نمره و بازخورد'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'رد نمونه‌کار',
                  onPressed: () => _reject(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.danger),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _review(BuildContext context) async {
    final scoreCtrl = TextEditingController();
    final feedbackCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نمره‌دهی «${item.title}»'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: scoreCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'نمره (از ۲۰)'),
            ),
            const SizedBox(height: 10),
            TextField(controller: feedbackCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'بازخورد برای هنرجو')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ارسال برای مدیر')),
        ],
      ),
    );

    final score = double.tryParse(scoreCtrl.text.trim());
    if (ok == true && score != null) {
      await PortfolioService.teacherReview(
        id: item.id,
        score: score,
        feedback: feedbackCtrl.text.trim(),
        teacherPhone: CurrentUser.phone,
      );
      onDone();
    }
  }

  Future<void> _reject(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رد نمونه‌کار'),
        content: TextField(controller: reasonCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'دلیل رد')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('رد نمونه‌کار')),
        ],
      ),
    );
    if (ok == true) {
      await PortfolioService.teacherReject(id: item.id, feedback: reasonCtrl.text.trim(), teacherPhone: CurrentUser.phone);
      onDone();
    }
  }
}
