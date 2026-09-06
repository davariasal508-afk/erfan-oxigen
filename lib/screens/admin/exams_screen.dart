import 'package:flutter/material.dart';
import '../../models/exam_model.dart';
import '../../services/exam_service.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import 'add_exam_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});
  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  @override
  Widget build(BuildContext context) {
    final exams = ExamService.exams;
    return OxygenPage(
      title: 'آزمون و نمره',
      floatingActionButton: FloatingActionButton.extended(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExamScreen())); if (mounted) setState(() {}); }, backgroundColor: AppTheme.gold, foregroundColor: Colors.black, icon: const Icon(Icons.add), label: const Text('آزمون جدید')),
      child: exams.isEmpty ? const Center(child: Text('آزمونی ثبت نشده است', style: TextStyle(color: AppTheme.muted))) : ListView.separated(padding: const EdgeInsets.fromLTRB(18, 14, 18, 30), itemCount: exams.length, separatorBuilder: (context, index) => const SizedBox(height: 12), itemBuilder: (context, index) => _card(exams[index])),
    );
  }

  Widget _card(ExamModel exam) {
    final teacher = UserManager.users.where((u) => u.phone == exam.teacherPhone).firstOrNull;
    final student = UserManager.users.where((u) => u.phone == exam.studentPhone).firstOrNull;
    return Container(padding: const EdgeInsets.all(17), decoration: AppTheme.glass(radius: 20, strong: exam.scorePendingApproval), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 46, height: 46, decoration: AppTheme.goldGlow(radius: 14), child: Icon(exam.type == 'theory' ? Icons.quiz_rounded : Icons.handyman_rounded, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 3), Text('${teacher?.name ?? 'مدرس نامشخص'} ← ${student?.name ?? 'هنرجو نامشخص'}', style: const TextStyle(color: AppTheme.muted, fontSize: 11))])), if (exam.scorePendingApproval) const Icon(Icons.priority_high_rounded, color: AppTheme.gold)]), const SizedBox(height: 10), Text(exam.type == 'theory' ? '${exam.totalQuestions} سؤال • ${exam.multipleChoiceCount} تستی • ${exam.descriptiveCount} تشریحی' : 'ارزیابی عملی', style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 8), if (exam.scorePendingApproval) ...[Text('نمره پیشنهادی مدرس: ${exam.proposedScore?.toStringAsFixed(1)} از ۲۰', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900)), if (exam.teacherRequestedPublish) const Text('مدرس درخواست نمایش به هنرجو را داده است.', style: TextStyle(color: Colors.white70, fontSize: 11)), const SizedBox(height: 10), Row(children: [Expanded(child: FilledButton.icon(onPressed: () => _approve(exam), icon: const Icon(Icons.verified_rounded), label: const Text('تأیید و مدیریت نمایش'))), const SizedBox(width: 8), IconButton(onPressed: () => _reject(exam), tooltip: 'رد نمره', icon: const Icon(Icons.close_rounded, color: Colors.redAccent))])] else if (exam.score != null) ...[Text('نمره نهایی: ${exam.score!.toStringAsFixed(1)} از ۲۰', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.success)), const SizedBox(height: 4), Text(exam.scorePublished ? 'برای هنرجو نمایش داده می‌شود' : 'تأیید شده ولی هنوز به هنرجو نمایش داده نمی‌شود', style: const TextStyle(color: AppTheme.muted, fontSize: 11))] ]));
  }

  Future<void> _approve(ExamModel exam) async {
    final score = TextEditingController(text: exam.proposedScore?.toString() ?? '');
    final note = TextEditingController();
    bool publish = exam.teacherRequestedPublish;
    final ok = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(title: const Text('تأیید نمره'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('نمره مدرس: ${exam.proposedScore?.toStringAsFixed(1)} از ۲۰', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 12), TextField(controller: score, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'نمره نهایی (قابل اصلاح)')), const SizedBox(height: 10), TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'یادداشت مدیر')), SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('نمایش نمره برای هنرجو'), value: publish, onChanged: (v) => setState(() => publish = v))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('تأیید'))])));
    if (ok == true) { await ExamService.approveScore(examId: exam.id, adjustedScore: double.tryParse(score.text), publishToStudent: publish, adminNote: note.text); if (mounted) setState(() {}); }
    score.dispose(); note.dispose();
  }

  Future<void> _reject(ExamModel exam) async {
    final note = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('رد درخواست نمره'), content: TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'دلیل رد')), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('رد درخواست'))]));
    if (ok == true) { await ExamService.rejectScore(exam.id, note: note.text.trim()); if (mounted) setState(() {}); }
    note.dispose();
  }
}

extension<T> on Iterable<T> { T? get firstOrNull => isEmpty ? null : first; }
