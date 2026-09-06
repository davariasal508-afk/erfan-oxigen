import 'package:flutter/material.dart';
import '../../models/exam_model.dart';
import '../../services/current_user.dart';
import '../../services/exam_service.dart';
import 'take_exam_screen.dart';
import '../../theme/app_theme.dart';

class ExamOverviewScreen extends StatefulWidget {
  final String title;
  final bool teacherView;
  final bool studentView;
  const ExamOverviewScreen({super.key, required this.title, this.teacherView = false, this.studentView = false});
  @override
  State<ExamOverviewScreen> createState() => _ExamOverviewScreenState();
}

class _ExamOverviewScreenState extends State<ExamOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final all = widget.teacherView ? ExamService.getTeacherExams(CurrentUser.phone) : widget.studentView ? ExamService.getStudentExams(CurrentUser.phone) : ExamService.exams;
    return OxygenPage(title: widget.title, child: all.isEmpty ? const Center(child: Text('موردی برای نمایش وجود ندارد', style: TextStyle(color: AppTheme.muted))) : ListView.separated(padding: const EdgeInsets.all(18), itemCount: all.length, separatorBuilder: (context, index) => const SizedBox(height: 12), itemBuilder: (context, index) => _card(all[index])));
  }

  Widget _card(ExamModel exam) {
    final type = exam.type == 'theory' ? 'تئوری' : 'عملی';
    return Container(padding: const EdgeInsets.all(17), decoration: AppTheme.glass(radius: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 46, height: 46, decoration: AppTheme.goldGlow(radius: 14), child: Icon(exam.type == 'theory' ? Icons.quiz_rounded : Icons.handyman_rounded, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(999)), child: Text(type, style: const TextStyle(color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.w800))) ]), const SizedBox(height: 10), Text(exam.description.isEmpty ? 'بدون توضیحات' : exam.description, style: const TextStyle(color: AppTheme.muted, height: 1.45)), const SizedBox(height: 8), if (exam.type == 'theory') Text('${exam.totalQuestions} سؤال • ${exam.multipleChoiceCount} تستی • ${exam.descriptiveCount} تشریحی', style: const TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 8), if (widget.studentView) ...[
            if (exam.scorePublished && exam.score != null) Text('نمره نهایی: ${exam.score!.toStringAsFixed(1)} از ۲۰', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.success)),
            if (!exam.submitted && exam.isTheory) ...[const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => TakeExamScreen(exam: exam))); if (mounted) setState(() {}); }, icon: const Icon(Icons.play_arrow_rounded), label: const Text('شروع آزمون')))],
            if (exam.submitted && !exam.scorePublished) const Padding(padding: EdgeInsets.only(top: 6), child: Text('آزمون ارسال شده و در حال بررسی است.', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800))),
          ], if (widget.teacherView) ...[if (exam.scorePendingApproval) const Text('در انتظار تأیید مدیر', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Align(alignment: Alignment.centerLeft, child: FilledButton.icon(onPressed: () => _grade(exam), icon: const Icon(Icons.rate_review_rounded), label: const Text('ثبت نمره')))] ]));
  }

  Future<void> _grade(ExamModel exam) async {
    final score = TextEditingController(text: exam.proposedScore?.toString() ?? exam.score?.toString() ?? '');
    final note = TextEditingController();
    bool publish = false;
    final ok = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(title: Text('نمره‌دهی • ${exam.title}'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: score, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'نمره از ۲۰')), const SizedBox(height: 10), TextField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'یادداشت مدرس')), SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('درخواست نمایش به هنرجو'), value: publish, onChanged: (v) => setState(() => publish = v))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ارسال برای تأیید'))])));
    if (ok == true) { final value = double.tryParse(score.text); if (value != null) await ExamService.proposeScore(examId: exam.id, teacherPhone: CurrentUser.phone, score: value, requestPublish: publish, note: note.text); if (mounted) setState(() {}); }
    score.dispose(); note.dispose();
  }
}
