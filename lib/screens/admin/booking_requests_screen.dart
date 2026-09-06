import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';

/// «درخواست‌های نوبت» — تأیید، رد یا تغییر زمان نوبت مشتری توسط مدیر.
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = BookingService.pendingForManager();
    final all = BookingService.items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return OxygenPage(
      title: 'درخواست‌های نوبت',
      child: Column(
        children: [
          TabBar(
            controller: _tab,
            labelColor: AppTheme.gold,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppTheme.gold,
            tabs: [Tab(text: 'در انتظار (${pending.length})'), const Tab(text: 'همه نوبت‌ها')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                pending.isEmpty
                    ? const Center(child: Text('درخواست جدیدی وجود ندارد.', style: TextStyle(color: AppTheme.muted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        itemCount: pending.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _RequestCard(booking: pending[index], onDone: () => setState(() {})),
                      ),
                ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                  itemCount: all.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _HistoryRow(booking: all[index]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onDone;
  const _RequestCard({required this.booking, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppTheme.surface2, AppTheme.surface]),
        border: Border.all(color: AppTheme.gold.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.gold.withValues(alpha: .35), width: 2), color: Colors.black),
                child: const Icon(Icons.person_rounded, color: AppTheme.gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.surface2, borderRadius: BorderRadius.circular(99), border: Border.all(color: AppTheme.gold.withValues(alpha: .3))),
                          child: const Text('جدید', style: TextStyle(color: AppTheme.gold, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(booking.service, style: const TextStyle(color: AppTheme.muted, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.muted),
              const SizedBox(width: 6),
              Text('${_weekdayFa(booking.date.weekday)}، ${booking.date.year}/${booking.date.month.toString().padLeft(2, '0')}/${booking.date.day.toString().padLeft(2, '0')} — ساعت ${booking.time}', style: const TextStyle(fontSize: 11.5, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reject(context),
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.danger),
                  label: const Text('رد', style: TextStyle(color: AppTheme.danger)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.danger)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reschedule(context),
                  icon: const Icon(Icons.schedule_rounded, size: 16),
                  label: const Text('تغییر زمان'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await BookingService.approve(booking.id);
                    onDone();
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('تأیید'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رد درخواست نوبت'),
        content: TextField(controller: reasonCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'دلیل (اختیاری)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('رد نوبت')),
        ],
      ),
    );
    if (ok == true) {
      await BookingService.cancel(booking.id, reason: reasonCtrl.text.trim());
      onDone();
    }
  }

  Future<void> _reschedule(BuildContext context) async {
    DateTime newDate = booking.date;
    final timeCtrl = TextEditingController(text: booking.time);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تغییر زمان نوبت'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${newDate.year}/${newDate.month.toString().padLeft(2, '0')}/${newDate.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_month_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) setState(() => newDate = picked);
                },
              ),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'ساعت جدید (مثلاً 17:30)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت')),
          ],
        ),
      ),
    );
    if (ok == true && timeCtrl.text.trim().isNotEmpty) {
      await BookingService.reschedule(booking.id, newDate: newDate, newTime: timeCtrl.text.trim());
      onDone();
    }
  }

  static String _weekdayFa(int w) => const ['دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه', 'یکشنبه'][w - 1];
}

class _HistoryRow extends StatelessWidget {
  final BookingModel booking;
  const _HistoryRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final color = switch (booking.status) {
      BookingStatus.confirmed => AppTheme.success,
      BookingStatus.cancelled => AppTheme.danger,
      BookingStatus.completed => AppTheme.info,
      _ => AppTheme.gold,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glass(radius: 16),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking.customerName} — ${booking.service}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                Text('${booking.date.year}/${booking.date.month.toString().padLeft(2, '0')}/${booking.date.day.toString().padLeft(2, '0')} • ${booking.time}', style: const TextStyle(color: AppTheme.muted, fontSize: 10.5)),
              ],
            ),
          ),
          Text(BookingService.statusLabel(booking.status), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
