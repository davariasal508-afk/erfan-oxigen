class ExamQuestion {
  String id;
  String prompt;
  String kind; // multiple_choice | descriptive
  List<String> options;
  int? correctOptionIndex;
  double points;
  String studentAnswer;
  double? teacherScore;

  ExamQuestion({
    required this.id,
    required this.prompt,
    required this.kind,
    this.options = const [],
    this.correctOptionIndex,
    this.points = 1,
    this.studentAnswer = '',
    this.teacherScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'kind': kind,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'points': points,
        'studentAnswer': studentAnswer,
        'teacherScore': teacherScore,
      };

  factory ExamQuestion.fromJson(Map<String, dynamic> json) => ExamQuestion(
        id: json['id'] ?? '',
        prompt: json['prompt'] ?? '',
        kind: json['kind'] ?? 'multiple_choice',
        options: List<String>.from(json['options'] ?? const []),
        correctOptionIndex: (json['correctOptionIndex'] as num?)?.toInt(),
        points: (json['points'] as num?)?.toDouble() ?? 1,
        studentAnswer: json['studentAnswer'] ?? '',
        teacherScore: json['teacherScore'] == null ? null : (json['teacherScore'] as num).toDouble(),
      );
}

class ExamModel {
  String id;
  String title;
  String description;
  String teacherPhone;
  String studentPhone;
  String type;
  int totalQuestions;
  int multipleChoiceCount;
  int descriptiveCount;
  List<ExamQuestion> questions;
  double? autoScore;
  bool submitted;
  double? proposedScore;
  double? score;
  bool scorePendingApproval;
  bool scorePublished;
  bool teacherRequestedPublish;
  String? teacherNote;
  String? adminNote;
  String date;
  String? gradedAt;
  String? publishedAt;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherPhone,
    required this.studentPhone,
    this.type = 'practical',
    this.totalQuestions = 1,
    this.multipleChoiceCount = 0,
    this.descriptiveCount = 0,
    this.questions = const [],
    this.autoScore,
    this.submitted = false,
    this.proposedScore,
    this.score,
    this.scorePendingApproval = false,
    this.scorePublished = false,
    this.teacherRequestedPublish = false,
    this.teacherNote,
    this.adminNote,
    required this.date,
    this.gradedAt,
    this.publishedAt,
  });

  bool get isTheory => type == 'theory';
  bool get isPractical => type == 'practical';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'teacherPhone': teacherPhone,
        'studentPhone': studentPhone,
        'type': type,
        'totalQuestions': totalQuestions,
        'multipleChoiceCount': multipleChoiceCount,
        'descriptiveCount': descriptiveCount,
        'questions': questions.map((e) => e.toJson()).toList(),
        'autoScore': autoScore,
        'submitted': submitted,
        'proposedScore': proposedScore,
        'score': score,
        'scorePendingApproval': scorePendingApproval,
        'scorePublished': scorePublished,
        'teacherRequestedPublish': teacherRequestedPublish,
        'teacherNote': teacherNote,
        'adminNote': adminNote,
        'date': date,
        'gradedAt': gradedAt,
        'publishedAt': publishedAt,
      };

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        teacherPhone: json['teacherPhone'] ?? '',
        studentPhone: json['studentPhone'] ?? '',
        type: json['type'] ?? 'practical',
        totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 1,
        multipleChoiceCount: (json['multipleChoiceCount'] as num?)?.toInt() ?? 0,
        descriptiveCount: (json['descriptiveCount'] as num?)?.toInt() ?? 0,
        questions: (json['questions'] as List?)?.map((e) => ExamQuestion.fromJson(Map<String, dynamic>.from(e))).toList() ?? const [],
        autoScore: json['autoScore'] == null ? null : (json['autoScore'] as num).toDouble(),
        submitted: json['submitted'] ?? false,
        proposedScore: json['proposedScore'] == null ? null : (json['proposedScore'] as num).toDouble(),
        score: json['score'] == null ? null : (json['score'] as num).toDouble(),
        scorePendingApproval: json['scorePendingApproval'] ?? false,
        scorePublished: json['scorePublished'] ?? false,
        teacherRequestedPublish: json['teacherRequestedPublish'] ?? false,
        teacherNote: json['teacherNote'],
        adminNote: json['adminNote'],
        date: json['date'] ?? '',
        gradedAt: json['gradedAt'],
        publishedAt: json['publishedAt'],
      );
}
