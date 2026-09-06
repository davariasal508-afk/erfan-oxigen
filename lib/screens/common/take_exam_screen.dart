import 'package:flutter/material.dart';
import '../../models/exam_model.dart';
import '../../services/exam_service.dart';
import '../../theme/app_theme.dart';

class TakeExamScreen extends StatefulWidget {
  final ExamModel exam;
  const TakeExamScreen({super.key, required this.exam});
  @override
  State<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends State<TakeExamScreen> {
  final answers = <String, String>{};
  bool sending = false;

  Future<void> submit() async {
    setState(() => sending = true);
    await ExamService.submitAnswers(widget.exam.id, answers);
    if (!mounted) return;
    setState(() => sending = false);
    await showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('آزمون ارسال شد'), content: const Text('پاسخ‌ها ثبت شدند. سوالات تستی امتیاز اولیه گرفته‌اند و سوالات تشریحی در اختیار مدرس قرار می‌گیرند.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('باشه'))]));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return OxygenPage(title: widget.exam.title, child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 30), children: [Container(padding: const EdgeInsets.all(16), decoration: AppTheme.glass(radius: 20, strong: true), child: Row(children: [const Icon(Icons.quiz_rounded, color: AppTheme.gold), const SizedBox(width: 10), Expanded(child: Text('${widget.exam.totalQuestions} سؤال • ${widget.exam.multipleChoiceCount} تستی • ${widget.exam.descriptiveCount} تشریحی', style: const TextStyle(fontWeight: FontWeight.w800)))])), const SizedBox(height: 12), ...widget.exam.questions.asMap().entries.map((entry) => _question(entry.key + 1, entry.value)), const SizedBox(height: 18), SizedBox(height: 54, child: ElevatedButton.icon(onPressed: sending ? null : submit, icon: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Icon(Icons.send_rounded), label: Text(sending ? 'در حال ارسال...' : 'ارسال آزمون')))]));
  }

  Widget _question(int index, ExamQuestion question) {
    if (question.kind == 'multiple_choice') {
      return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: AppTheme.glass(radius: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$index. ${question.prompt}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), ...List.generate(
        question.options.length,
        (i) {
          final selected = answers[question.id] == '$i';
          return InkWell(
            onTap: () => setState(() => answers[question.id] = '$i'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? AppTheme.gold : Colors.white38,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(question.options[i])),
                ],
              ),
            ),
          );
        },
      )]));
    }
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15), decoration: AppTheme.glass(radius: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$index. ${question.prompt}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), TextField(minLines: 3, maxLines: 6, onChanged: (v) => answers[question.id] = v, decoration: const InputDecoration(hintText: 'پاسخ تشریحی خود را بنویسید...'))]));
  }
}
