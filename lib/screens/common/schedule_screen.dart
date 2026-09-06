import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';
import '../../services/current_user.dart';
import '../../services/schedule_service.dart';
import '../../services/view_tracking_service.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  final String title;
  const ScheduleScreen({super.key, this.title = 'برنامه کلاس‌ها'});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    _markViews();
  }

  Future<void> _markViews() async {
    for (final item in ScheduleService.items.where((e) => e.active)) {
      await ViewTrackingService.markViewed(type: 'schedule', itemId: item.id, viewerPhone: CurrentUser.phone, viewerName: CurrentUser.name);
    }
  }

  Future<void> _edit([ScheduleItem? item]) async {
    final day = TextEditingController(text: item?.day ?? 'شنبه');
    final title = TextEditingController(text: item?.title ?? '');
    final time = TextEditingController(text: item?.time ?? '');
    final room = TextEditingController(text: item?.room ?? '');
    final notes = TextEditingController(text: item?.notes ?? '');
    final result = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: Text(item == null ? 'برنامه جدید' : 'ویرایش برنامه'), content: SingleChildScrollView(child: Column(children: [TextField(controller: day, decoration: const InputDecoration(labelText: 'روز')), const SizedBox(height: 8), TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان کلاس')), const SizedBox(height: 8), TextField(controller: time, decoration: const InputDecoration(labelText: 'ساعت')), const SizedBox(height: 8), TextField(controller: room, decoration: const InputDecoration(labelText: 'اتاق / استودیو')), const SizedBox(height: 8), TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات'))])), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ذخیره'))]));
    if (result == true) {
      final value = ScheduleItem(id: item?.id ?? 'schedule_${DateTime.now().microsecondsSinceEpoch}', day: day.text.trim(), title: title.text.trim(), time: time.text.trim(), room: room.text.trim(), notes: notes.text.trim(), teacherPhone: item?.teacherPhone ?? '');
      await ScheduleService.upsert(value);
      if (mounted) setState(() {});
    }
    day.dispose(); title.dispose(); time.dispose(); room.dispose(); notes.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = CurrentUser.role == 'admin';
    final items = ScheduleService.items.where((e) => e.active).toList();
    return OxygenPage(
      title: widget.title,
      floatingActionButton: admin
          ? FloatingActionButton.extended(
              onPressed: () => _edit(),
              backgroundColor: AppTheme.gold,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add),
              label: const Text('برنامه جدید'),
            )
          : null,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final viewers = ViewTrackingService.viewers('schedule', item.id);
          final actions = <Widget>[];
          if (admin) {
            actions.add(IconButton(tooltip: 'مشاهده کاربران', onPressed: () => _showViewers(item, viewers), icon: const Icon(Icons.visibility_rounded, color: AppTheme.gold)));
            actions.add(IconButton(tooltip: 'ویرایش', onPressed: () => _edit(item), icon: const Icon(Icons.edit_rounded)));
            actions.add(IconButton(tooltip: 'حذف', onPressed: () async { await ScheduleService.remove(item.id); if (mounted) setState(() {}); }, icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent)));
          }
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glass(radius: 20),
            child: Row(
              children: [
                Container(width: 54, height: 54, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.calendar_month_rounded, color: Colors.black)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${item.day} • ${item.time}', style: const TextStyle(color: AppTheme.muted)),
                    if (item.room.isNotEmpty) Text(item.room, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    if (item.notes.isNotEmpty) Text(item.notes, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ]),
                ),
                ...actions,
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showViewers(ScheduleItem item, List viewers) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مشاهده برنامه • ${item.title}'),
        content: viewers.isEmpty ? const Text('هیچ بازدیدی ثبت نشده است.') : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: viewers.map((v) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('• ${v.viewerName}'))).toList(),),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن'))],
      ),
    );
  }

}
