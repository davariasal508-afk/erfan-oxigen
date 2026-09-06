class FormulaModel {
  final String id;
  final String name;
  final double hue;
  final double lightener;
  final double toner;
  final double baseColor;
  final double ratio;
  final DateTime createdAt;

  FormulaModel({
    required this.id,
    required this.name,
    required this.hue,
    required this.lightener,
    required this.toner,
    required this.baseColor,
    required this.ratio,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hue': hue,
        'lightener': lightener,
        'toner': toner,
        'baseColor': baseColor,
        'ratio': ratio,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FormulaModel.fromJson(Map<String, dynamic> json) => FormulaModel(
        id: json['id'] ?? '',
        name: json['name'] ?? 'فرمول',
        hue: (json['hue'] as num?)?.toDouble() ?? 0,
        lightener: (json['lightener'] as num?)?.toDouble() ?? 40,
        toner: (json['toner'] as num?)?.toDouble() ?? 30,
        baseColor: (json['baseColor'] as num?)?.toDouble() ?? 20,
        ratio: (json['ratio'] as num?)?.toDouble() ?? 10,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}
