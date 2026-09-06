import 'package:flutter/material.dart';
import '../../models/exam_model.dart';
import '../../services/exam_service.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class AddExamScreen extends StatefulWidget {
  const AddExamScreen({super.key});
  @override
  State<AddExamScreen> createState() => _AddExamScreenState();
}

class _QuestionDraft {
  final TextEditingController prompt = TextEditingController();
  final List<TextEditingController> options = List.generate(4, (_) => TextEditingController());
  int? correct;
  void dispose() { prompt.dispose(); for (final c in options) { c.dispose(); } }
}

class _AddExamScreenState extends State<AddExamScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final total = TextEditingController(text: '20');
  final mc = TextEditingController(text: '10');
  final essay = TextEditingController(text: '10');
  String type = 'theory';
  String? teacherPhone;
  String? studentPhone;
  final List<_QuestionDraft> drafts = [];

  @override
  void initState() {
    super.initState();
    final teachers = UserManager.getUsersByRole('teacher');
    final students = UserManager.getUsersByRole('student');
    teacherPhone = teachers.isNotEmpty ? teachers.first.phone : null;
    studentPhone = students.isNotEmpty ? students.first.phone : null;
    final count = ((int.tryParse(total.text) ?? 20).clamp(1, 100)).toInt();
    while (drafts.length < count) {
      drafts.add(_QuestionDraft());
    }
  }

  void _syncDrafts() {
    final count = ((int.tryParse(total.text) ?? 20).clamp(1, 100)).toInt();
    while (drafts.length < count) {
      drafts.add(_QuestionDraft());
    }
    while (drafts.length > count) {
      drafts.removeLast().dispose();
    }
    if (mounted) setState(() {});
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty || teacherPhone == null || studentPhone == null) {
      _snack('عنوان، مدرس و هنرجو الزامی است.');
      return;
    }
    final totalCount = int.tryParse(total.text) ?? 20;
    final mcCount = type == 'theory' ? (int.tryParse(mc.text) ?? 0) : 0;
    final essayCount = type == 'theory' ? (int.tryParse(essay.text) ?? 0) : 0;
    if (type == 'theory' && mcCount + essayCount != totalCount) {
      _snack('تعداد تستی و تشریحی باید برابر تعداد کل سؤالات باشد.');
      return;
    }
    if (type == 'theory') {
      for (var i = 0; i < totalCount; i++) {
        final isMc = i < mcCount;
        if (drafts[i].prompt.text.trim().isEmpty) {
          _snack('متن سؤال ${i + 1} را وارد کنید.');
          return;
        }
        if (isMc) {
          if (drafts[i].options.any((c) => c.text.trim().isEmpty) || drafts[i].correct == null) {
            _snack('برای سؤال تستی ${i + 1}، چهار گزینه و پاسخ صحیح را وارد کنید.');
            return;
          }
        }
      }
    }
    final questions = type == 'theory'
        ? List.generate(totalCount, (i) => ExamQuestion(id: 'q_${DateTime.now().microsecondsSinceEpoch}_$i', prompt: drafts[i].prompt.text.trim(), kind: i < mcCount ? 'multiple_choice' : 'descriptive', options: i < mcCount ? drafts[i].options.map((c) => c.text.trim()).toList() : const [], correctOptionIndex: i < mcCount ? drafts[i].correct : null, points: 20 / totalCount))
        : <ExamQuestion>[];
    await ExamService.addExam(ExamModel(id: 'exam_${DateTime.now().microsecondsSinceEpoch}', title: title.text.trim(), description: desc.text.trim(), teacherPhone: teacherPhone!, studentPhone: studentPhone!, type: type, totalQuestions: totalCount, multipleChoiceCount: mcCount, descriptiveCount: essayCount, questions: questions, date: DateTime.now().toIso8601String()));
    if (mounted) Navigator.pop(context, true);
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  void dispose() {
    title.dispose(); desc.dispose(); total.dispose(); mc.dispose(); essay.dispose(); for (final d in drafts) { d.dispose(); } super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teachers = UserManager.getUsersByRole('teacher');
    final students = UserManager.getUsersByRole('student');
    final count = ((int.tryParse(total.text) ?? 20).clamp(1, 100)).toInt();
    final mcCount = ((int.tryParse(mc.text) ?? 10).clamp(0, count)).toInt();
    return OxygenPage(title: 'ساخت آزمون', child: ListView(padding: const EdgeInsets.all(18), children: [
      const SectionTitle(title: 'آزمون تئوری / عملی', subtitle: 'نمره نهایی بعد از بررسی مدرس برای تأیید مدیر می‌رود.'),
      const SizedBox(height: 12),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان آزمون')),
      const SizedBox(height: 10),
      TextField(controller: desc, maxLines: 3, decoration: const InputDecoration(labelText: 'توضیحات')),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: type, items: const [DropdownMenuItem(value: 'theory', child: Text('تئوری')), DropdownMenuItem(value: 'practical', child: Text('عملی'))], onChanged: (v) => setState(() => type = v ?? type), decoration: const InputDecoration(labelText: 'نوع آزمون')),
      const SizedBox(height: 10),
      if (type == 'theory') ...[
        Row(children: [Expanded(child: TextField(controller: total, keyboardType: TextInputType.number, onChanged: (_) { _syncDrafts(); }, decoration: const InputDecoration(labelText: 'تعداد کل سؤالات'))), const SizedBox(width: 10), Expanded(child: TextField(controller: mc, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'تستی'))), const SizedBox(width: 10), Expanded(child: TextField(controller: essay, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'تشریحی')))]),
        const SizedBox(height: 10),
        Text('تعداد تستی: $mcCount • تشریحی: ${count - mcCount}', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
        const SizedBox(height: 10),
        ...List.generate(count, (i) => _questionCard(i, i < mcCount)),
      ],
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: teacherPhone, items: teachers.map((u) => DropdownMenuItem(value: u.phone, child: Text(u.name))).toList(), onChanged: (v) => setState(() => teacherPhone = v), decoration: const InputDecoration(labelText: 'مدرس')),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(initialValue: studentPhone, items: students.map((u) => DropdownMenuItem(value: u.phone, child: Text(u.name))).toList(), onChanged: (v) => setState(() => studentPhone = v), decoration: const InputDecoration(labelText: 'هنرجو')),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(14), decoration: AppTheme.glass(radius: 18), child: Row(children: [const Icon(Icons.verified_rounded, color: AppTheme.gold), const SizedBox(width: 10), Expanded(child: Text(type == 'theory' ? 'نمونه پیشنهادی: ۲۰ سؤال با ۱۰ تستی + ۱۰ تشریحی. تستی‌ها هنگام ارسال خودکار نمره می‌گیرند و تشریحی برای مدرس می‌ماند.' : 'آزمون عملی با تحویل کار و نمره‌دهی مدرس ثبت می‌شود.', style: const TextStyle(color: AppTheme.muted, height: 1.5)))])),
      const SizedBox(height: 18),
      SizedBox(height: 54, child: ElevatedButton.icon(onPressed: save, icon: const Icon(Icons.save_rounded), label: const Text('ثبت آزمون'))),
    ]));
  }

  Widget _questionCard(int index, bool multipleChoice) {
    final d = drafts[index];
    final children = <Widget>[
      TextField(
        controller: d.prompt,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'صورت سؤال'),
      ),
    ];
    if (multipleChoice) {
      children.addAll([
        const SizedBox(height: 8),
        ...List.generate(4, (optionIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => d.correct = optionIndex),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    child: Icon(
                      d.correct == optionIndex
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: d.correct == optionIndex ? AppTheme.gold : Colors.white38,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: d.options[optionIndex],
                    decoration: InputDecoration(labelText: 'گزینه ${optionIndex + 1}'),
                  ),
                ),
              ],
            ),
          );
        }),
      ]);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.glass(radius: 18),
      child: ExpansionTile(
        title: Text('سؤال ${index + 1} • ${multipleChoice ? 'تستی' : 'تشریحی'}', style: const TextStyle(fontWeight: FontWeight.w800)),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: children,
      ),
    );
  }

}
