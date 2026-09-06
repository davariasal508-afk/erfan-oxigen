class BookingStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const cancelled = 'cancelled';
  static const completed = 'completed';
}

class BookingModel {
  final String id;
  final String customerPhone;
  final String customerName;
  String service;
  DateTime date;
  String time;
  String status;
  final DateTime createdAt;
  String? managerNote;
  DateTime? decidedAt;

  BookingModel({
    required this.id,
    required this.customerPhone,
    required this.customerName,
    required this.service,
    required this.date,
    required this.time,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
    this.managerNote,
    this.decidedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerPhone': customerPhone,
        'customerName': customerName,
        'service': service,
        'date': date.toIso8601String(),
        'time': time,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'managerNote': managerNote,
        'decidedAt': decidedAt?.toIso8601String(),
      };

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] ?? '',
        customerPhone: json['customerPhone'] ?? '',
        customerName: json['customerName'] ?? 'مشتری',
        service: json['service'] ?? '',
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        time: json['time'] ?? '',
        status: json['status'] ?? BookingStatus.pending,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        managerNote: json['managerNote'],
        decidedAt: json['decidedAt'] == null ? null : DateTime.tryParse(json['decidedAt']),
      );
}
