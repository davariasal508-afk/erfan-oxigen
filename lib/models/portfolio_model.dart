/// وضعیت گردش‌کار نمونه‌کار (Portfolio Workflow)
/// draft -> pending_teacher -> teacher_reviewed -> pending_manager -> approved
/// یا در هر مرحله از سمت مدرس: rejected
class PortfolioStatus {
  static const draft = 'draft';
  static const pendingTeacher = 'pending_teacher';
  static const teacherReviewed = 'teacher_reviewed';
  static const pendingManager = 'pending_manager';
  static const approved = 'approved';
  static const rejected = 'rejected';
}

class PortfolioModel {
  final String id;
  final String studentPhone;
  final String studentName;
  String title;
  String description;
  String imagePath;
  String? courseId;
  final DateTime createdAt;

  String status;

  double? teacherScore;
  String? teacherFeedback;
  String? teacherPhone;
  DateTime? teacherReviewedAt;

  double? managerScore;
  String? managerFeedback;
  String? managerPhone;
  DateTime? managerDecisionAt;
  bool managerAcceptedTeacherScore;

  PortfolioModel({
    required this.id,
    required this.studentPhone,
    required this.studentName,
    required this.title,
    required this.description,
    required this.imagePath,
    this.courseId,
    DateTime? createdAt,
    this.status = PortfolioStatus.pendingTeacher,
    this.teacherScore,
    this.teacherFeedback,
    this.teacherPhone,
    this.teacherReviewedAt,
    this.managerScore,
    this.managerFeedback,
    this.managerPhone,
    this.managerDecisionAt,
    this.managerAcceptedTeacherScore = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// نمره نهایی طبق قانون بخش ۹:
  /// اگر مدیر نمره جایگزین ثبت نکرده باشد -> نمره مدرس
  /// اگر مدیر نمره جایگزین ثبت کرده باشد -> فقط نمره مدیر
  double? get finalScore {
    if (status != PortfolioStatus.approved) return null;
    if (!managerAcceptedTeacherScore && managerScore != null) return managerScore;
    return teacherScore;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentPhone': studentPhone,
        'studentName': studentName,
        'title': title,
        'description': description,
        'imagePath': imagePath,
        'courseId': courseId,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'teacherScore': teacherScore,
        'teacherFeedback': teacherFeedback,
        'teacherPhone': teacherPhone,
        'teacherReviewedAt': teacherReviewedAt?.toIso8601String(),
        'managerScore': managerScore,
        'managerFeedback': managerFeedback,
        'managerPhone': managerPhone,
        'managerDecisionAt': managerDecisionAt?.toIso8601String(),
        'managerAcceptedTeacherScore': managerAcceptedTeacherScore,
      };

  factory PortfolioModel.fromJson(Map<String, dynamic> json) => PortfolioModel(
        id: json['id'] ?? '',
        studentPhone: json['studentPhone'] ?? '',
        studentName: json['studentName'] ?? 'هنرجو',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imagePath: json['imagePath'] ?? '',
        courseId: json['courseId'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? PortfolioStatus.pendingTeacher,
        teacherScore: (json['teacherScore'] as num?)?.toDouble(),
        teacherFeedback: json['teacherFeedback'],
        teacherPhone: json['teacherPhone'],
        teacherReviewedAt: json['teacherReviewedAt'] == null ? null : DateTime.tryParse(json['teacherReviewedAt']),
        managerScore: (json['managerScore'] as num?)?.toDouble(),
        managerFeedback: json['managerFeedback'],
        managerPhone: json['managerPhone'],
        managerDecisionAt: json['managerDecisionAt'] == null ? null : DateTime.tryParse(json['managerDecisionAt']),
        managerAcceptedTeacherScore: json['managerAcceptedTeacherScore'] ?? true,
      );
}
