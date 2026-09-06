class NotificationModel {
  final String id;
  final String targetPhone;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final DateTime createdAt;
  bool read;

  NotificationModel({
    required this.id,
    required this.targetPhone,
    required this.title,
    required this.body,
    this.type = 'general',
    this.relatedId,
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetPhone': targetPhone,
        'title': title,
        'body': body,
        'type': type,
        'relatedId': relatedId,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] ?? '',
        targetPhone: json['targetPhone'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'] ?? 'general',
        relatedId: json['relatedId'],
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        read: json['read'] ?? false,
      );
}
