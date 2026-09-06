class AdModel {
  final String id;
  String title;
  String description;
  String category;
  int oldPrice;
  int price;
  int discountPercent;
  DateTime startsAt;
  DateTime endsAt;
  bool active;
  bool pinned;
  String targetRole;
  String promoCode;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    this.category = 'دوره',
    this.oldPrice = 0,
    this.price = 0,
    this.discountPercent = 0,
    DateTime? startsAt,
    DateTime? endsAt,
    this.active = true,
    this.pinned = false,
    this.targetRole = 'all',
    this.promoCode = '',
  })  : startsAt = startsAt ?? DateTime.now(),
        endsAt = endsAt ?? DateTime.now().add(const Duration(days: 7));

  bool get isFlashSale => endsAt.difference(DateTime.now()).inHours <= 24;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'oldPrice': oldPrice,
        'price': price,
        'discountPercent': discountPercent,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'active': active,
        'pinned': pinned,
        'targetRole': targetRole,
        'promoCode': promoCode,
      };

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? 'دوره',
        oldPrice: (json['oldPrice'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toInt() ?? 0,
        discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
        startsAt: DateTime.tryParse(json['startsAt'] ?? ''),
        endsAt: DateTime.tryParse(json['endsAt'] ?? ''),
        active: json['active'] ?? true,
        pinned: json['pinned'] ?? false,
        targetRole: json['targetRole'] ?? 'all',
        promoCode: json['promoCode'] ?? '',
      );
}
