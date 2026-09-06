class ViewEventModel {
  final String type;
  final String itemId;
  final String viewerPhone;
  final String viewerName;
  final DateTime viewedAt;

  ViewEventModel({
    required this.type,
    required this.itemId,
    required this.viewerPhone,
    required this.viewerName,
    DateTime? viewedAt,
  }) : viewedAt = viewedAt ?? DateTime.now();

  String get key => '$type|$itemId|$viewerPhone';

  Map<String, dynamic> toJson() => {
        'type': type,
        'itemId': itemId,
        'viewerPhone': viewerPhone,
        'viewerName': viewerName,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory ViewEventModel.fromJson(Map<String, dynamic> json) => ViewEventModel(
        type: json['type'] ?? '',
        itemId: json['itemId'] ?? '',
        viewerPhone: json['viewerPhone'] ?? '',
        viewerName: json['viewerName'] ?? '',
        viewedAt: DateTime.tryParse(json['viewedAt'] ?? '') ?? DateTime.now(),
      );
}
