class ScheduleItem {
  final String id;
  String day;
  String title;
  String time;
  String room;
  String teacherPhone;
  String notes;
  bool active;
  DateTime updatedAt;

  ScheduleItem({
    required this.id,
    required this.day,
    required this.title,
    required this.time,
    this.room = '',
    this.teacherPhone = '',
    this.notes = '',
    this.active = true,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'title': title,
        'time': time,
        'room': room,
        'teacherPhone': teacherPhone,
        'notes': notes,
        'active': active,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id'] ?? '',
        day: json['day'] ?? '',
        title: json['title'] ?? '',
        time: json['time'] ?? '',
        room: json['room'] ?? '',
        teacherPhone: json['teacherPhone'] ?? '',
        notes: json['notes'] ?? '',
        active: json['active'] ?? true,
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );
}
