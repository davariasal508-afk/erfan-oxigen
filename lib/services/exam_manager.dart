import '../models/exam_model.dart';
import 'storage_service.dart';

class ExamManager {
  static final List<ExamModel> exams = [];

  static Future<void> initialize() async {
    final loadedExams = await StorageService.loadExams();

    exams
      ..clear()
      ..addAll(loadedExams);
  }

  static Future<void> loadExams() async {
    final loadedExams = await StorageService.loadExams();

    exams
      ..clear()
      ..addAll(loadedExams);
  }

  static Future<void> addExam(ExamModel exam) async {
    exams.add(exam);

    await StorageService.saveExams(exams);
  }

  static Future<void> updateExam(ExamModel oldExam, ExamModel newExam) async {
    final index = exams.indexWhere((exam) => exam.id == oldExam.id);

    if (index == -1) {
      return;
    }

    exams[index] = newExam;

    await StorageService.saveExams(exams);
  }

  static Future<void> removeExam(ExamModel exam) async {
    exams.removeWhere((item) => item.id == exam.id);

    await StorageService.saveExams(exams);
  }

  static ExamModel? getExamById(String id) {
    try {
      return exams.firstWhere((exam) => exam.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ExamModel> getActiveExams() {
    return List<ExamModel>.from(exams);
  }

  static List<ExamModel> getTeacherExams(String teacherPhone) {
    return exams.where((exam) => exam.teacherPhone == teacherPhone).toList();
  }

  static List<ExamModel> getStudentExams(String studentPhone) {
    return exams.where((exam) => exam.studentPhone == studentPhone).toList();
  }

  static Future<void> clearExams() async {
    exams.clear();

    await StorageService.clearExams();
  }
}
