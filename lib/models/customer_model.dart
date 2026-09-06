class CustomerModel {
  final String id;
  String name;
  final String phone;
  bool active;
  DateTime createdAt;
  DateTime? birthday;
  bool phoneVerified;
  int? birthdayGiftClaimedYear;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.active = true,
    DateTime? createdAt,
    this.birthday,
    this.phoneVerified = false,
    this.birthdayGiftClaimedYear,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'birthday': birthday?.toIso8601String(),
        'phoneVerified': phoneVerified,
        'birthdayGiftClaimedYear': birthdayGiftClaimedYear,
      };

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] ?? '',
        name: json['name'] ?? 'مشتری',
        phone: json['phone'] ?? '',
        active: json['active'] ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        birthday: json['birthday'] == null ? null : DateTime.tryParse(json['birthday'].toString()),
        phoneVerified: json['phoneVerified'] ?? false,
        birthdayGiftClaimedYear: (json['birthdayGiftClaimedYear'] as num?)?.toInt(),
      );

  bool get isBirthdayToday {
    final value = birthday;
    if (value == null) return false;
    final now = DateTime.now();
    return value.month == now.month && value.day == now.day;
  }

  bool get birthdayGiftAvailable {
    return isBirthdayToday && birthdayGiftClaimedYear != DateTime.now().year;
  }
}
