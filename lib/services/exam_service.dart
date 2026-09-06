import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam_model.dart';
import 'admin_profile_service.dart';
import 'notification_service.dart';
import 'user_manager.dart';

class ExamService {
  static const String examsKey = 'oxygen_exams';
  static List<ExamModel> exams = [];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(examsKey);
    if (data == null || data.isEmpty) {
      exams = [];
      return;
    }
    try {
      final decoded = jsonDecode(data) as List;
      exams = decoded.map((item) => ExamModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      exams = [];
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(examsKey, jsonEncode(exams.map((e) => e.toJson()).toList()));
  }

  static Future<void> addExam(ExamModel exam) async {
    exams.add(exam);
    await save();
  }

  static Future<void> updateExam(ExamModel exam) async {
    final index = exams.indexWhere((item) => item.id == exam.id);
    if (index == -1) return;
    exams[index] = exam;
    await save();
  }

  static Future<void> deleteExam(String id) async {
    exams.removeWhere((exam) => exam.id == id);
    await save();
  }

  static Future<void> submitAnswers(String examId, Map<String, String> answers) async {
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null) return;
    var autoPoints = 0.0;
    for (final question in exam.questions) {
      final answer = answers[question.id] ?? '';
      question.studentAnswer = answer;
      if (question.kind == 'multiple_choice') {
        if (question.correctOptionIndex != null && int.tryParse(answer) == question.correctOptionIndex) {
          autoPoints += question.points;
        }
      }
    }
    final totalMcPoints = exam.questions.where((q) => q.kind == 'multiple_choice').fold<double>(0, (sum, q) => sum + q.points);
    exam.autoScore = totalMcPoints <= 0 ? null : (autoPoints / totalMcPoints) * 10;
    exam.submitted = true;
    await save();
  }

  static Future<void> proposeScore({
    required String examId,
    required String teacherPhone,
    required double score,
    required bool requestPublish,
    String note = '',
  }) async {
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null) return;
    exam.proposedScore = score.clamp(0, 20).toDouble();
    exam.scorePendingApproval = true;
    exam.scorePublished = false;
    exam.teacherRequestedPublish = requestPublish;
    exam.teacherNote = note.trim().isEmpty ? null : note.trim();
    exam.gradedAt = DateTime.now().toIso8601String();
    await save();

    final teacher = UserManager.users.where((u) => u.phone == teacherPhone).firstOrNull;
    final student = UserManager.users.where((u) => u.phone == exam.studentPhone).firstOrNull;
    final admins = UserManager.getUsersByRole('admin').where((u) => u.active).toList();
    for (final admin in admins) {
      await NotificationService.add(
        targetPhone: admin.phone,
        title: 'درخواست تأیید نمره',
        body: '${teacher?.name ?? 'مدرس'} برای ${student?.name ?? 'هنرجو'} نمره ${exam.proposedScore!.toStringAsFixed(1)} از ۲۰ را پیشنهاد کرده است.${requestPublish ? ' درخواست نمایش به هنرجو نیز ثبت شده.' : ''}',
        type: 'grade_approval',
        relatedId: exam.id,
      );
    }
  }

  static Future<void> approveScore({
    required String examId,
    double? adjustedScore,
    required bool publishToStudent,
    String? adminNote,
  }) async {
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null || exam.proposedScore == null) return;
    exam.score = (adjustedScore ?? exam.proposedScore!).clamp(0, 20).toDouble();
    exam.adminNote = adminNote;
    exam.scorePendingApproval = false;
    exam.scorePublished = publishToStudent;
    exam.publishedAt = publishToStudent ? DateTime.now().toIso8601String() : null;
    await save();

    final student = UserManager.users.where((u) => u.phone == exam.studentPhone).firstOrNull;
    final teacher = UserManager.users.where((u) => u.phone == exam.teacherPhone).firstOrNull;
    if (student != null) {
      await NotificationService.add(
        targetPhone: student.phone,
        title: publishToStudent ? 'نمره شما منتشر شد' : 'نمره شما تأیید شد',
        body: '${exam.title}: ${exam.score!.toStringAsFixed(1)} از ۲۰',
        type: publishToStudent ? 'grade_published' : 'grade_approved',
        relatedId: exam.id,
      );
    }
    if (teacher != null) {
      await NotificationService.add(
        targetPhone: teacher.phone,
        title: 'نتیجه بررسی نمره',
        body: 'نمره ${exam.title} توسط ${AdminProfileService.displayName} بررسی و ${publishToStudent ? 'منتشر' : 'تأیید و مخفی'} شد.',
        type: 'grade_reviewed',
        relatedId: exam.id,
      );
    }
  }

  static Future<void> rejectScore(String examId, {String note = ''}) async {
    final exam = exams.where((e) => e.id == examId).firstOrNull;
    if (exam == null) return;
    final teacher = UserManager.users.where((u) => u.phone == exam.teacherPhone).firstOrNull;
    exam.scorePendingApproval = false;
    exam.proposedScore = null;
    exam.teacherRequestedPublish = false;
    exam.adminNote = note;
    await save();
    if (teacher != null) {
      await NotificationService.add(
        targetPhone: teacher.phone,
        title: 'درخواست نمره رد شد',
        body: note.isEmpty ? 'لطفاً نمره را دوباره بررسی و ارسال کنید.' : note,
        type: 'grade_rejected',
        relatedId: exam.id,
      );
    }
  }

  static List<ExamModel> getStudentExams(String studentPhone) => exams.where((exam) => exam.studentPhone == studentPhone).toList();
  static List<ExamModel> getVisibleStudentExams(String studentPhone) => exams.where((exam) => exam.studentPhone == studentPhone && exam.scorePublished).toList();
  static List<ExamModel> getTeacherExams(String teacherPhone) => exams.where((exam) => exam.teacherPhone == teacherPhone).toList();
  static List<ExamModel> getPendingApprovals() => exams.where((exam) => exam.scorePendingApproval).toList();

  static Future<void> clearAll() async {
    exams.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(examsKey);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
