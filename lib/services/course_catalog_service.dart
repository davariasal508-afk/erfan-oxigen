import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CourseCatalogItem {
  final String id;
  final String title;
  final String subtitle;
  final String sessions;
  final String category;
  final int price;
  final int? oldPrice;
  final String imageAsset;
  final String accent;
  final int capacity;

  const CourseCatalogItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sessions,
    required this.category,
    required this.price,
    required this.imageAsset,
    required this.accent,
    required this.capacity,
    this.oldPrice,
  });

  CourseCatalogItem copyWith({
    String? title,
    String? subtitle,
    String? sessions,
    String? category,
    int? price,
    int? oldPrice,
    String? imageAsset,
    int? capacity,
  }) {
    return CourseCatalogItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      sessions: sessions ?? this.sessions,
      category: category ?? this.category,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageAsset: imageAsset ?? this.imageAsset,
      accent: accent,
      capacity: capacity ?? this.capacity,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'sessions': sessions,
        'category': category,
        'price': price,
        'oldPrice': oldPrice,
        'imageAsset': imageAsset,
        'capacity': capacity,
      };

  static CourseCatalogItem fromBase(
    CourseCatalogItem base,
    Map<String, dynamic> json,
  ) {
    return base.copyWith(
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      sessions: json['sessions']?.toString(),
      category: json['category']?.toString(),
      price: (json['price'] as num?)?.round(),
      oldPrice: (json['oldPrice'] as num?)?.round(),
      imageAsset: json['imageAsset']?.toString(),
      capacity: (json['capacity'] as num?)?.round(),
    );
  }
}

class CourseCatalogService {
  static const String _key = 'erfan_oxygen_course_catalog_v2';

  static final List<CourseCatalogItem> _base = [
    const CourseCatalogItem(
      id: 'fade_mastery',
      title: 'Fade Mastery',
      subtitle: 'فید حرفه‌ای، انتقال تمیز و ساخت فرم صورت',
      sessions: '۱۰ جلسه • ۳ آزمون',
      category: 'Fade Lab',
      price: 4900000,
      oldPrice: 5600000,
      imageAsset: 'icon://content_cut',
      accent: 'gold',
      capacity: 6,
    ),
    const CourseCatalogItem(
      id: 'beard_design',
      title: 'Beard Design',
      subtitle: 'طراحی ریش، فرم‌دهی و استایل حرفه‌ای',
      sessions: '۸ جلسه • ۲ آزمون',
      category: 'Beard Lab',
      price: 3500000,
      oldPrice: 4100000,
      imageAsset: 'icon://beard',
      accent: 'bronze',
      capacity: 6,
    ),
    const CourseCatalogItem(
      id: 'color_for_men',
      title: 'Color for Men',
      subtitle: 'رنگ موی مردانه، فرمول‌نویسی و اصلاح تناژ',
      sessions: '۹ جلسه • ۲ آزمون',
      category: 'Color Lab',
      price: 4200000,
      oldPrice: 4800000,
      imageAsset: 'icon://palette',
      accent: 'cream',
      capacity: 8,
    ),
    const CourseCatalogItem(
      id: 'classic_cut',
      title: 'Classic Cut',
      subtitle: 'کات کلاسیک، قیچی‌کاری و استایل نهایی',
      sessions: '۶ جلسه • ۱ پروژه',
      category: 'Classic Barber',
      price: 3100000,
      oldPrice: 3600000,
      imageAsset: 'icon://razor',
      accent: 'gold',
      capacity: 8,
    ),
  ];

  static List<CourseCatalogItem> items = List<CourseCatalogItem>.from(_base);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final byId = <String, Map<String, dynamic>>{};
      for (final entry in decoded) {
        if (entry is Map) {
          final map = Map<String, dynamic>.from(entry);
          final id = map['id']?.toString();
          if (id != null) byId[id] = map;
        }
      }
      items = _base
          .map((base) => byId.containsKey(base.id)
              ? CourseCatalogItem.fromBase(base, byId[base.id]!)
              : base)
          .toList();
    } catch (_) {
      items = List<CourseCatalogItem>.from(_base);
    }
  }

  static CourseCatalogItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Future<void> updateCourse(
    String id, {
    String? title,
    String? subtitle,
    String? sessions,
    String? category,
    int? price,
    int? oldPrice,
    String? imageAsset,
    int? capacity,
  }) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    items[index] = items[index].copyWith(
      title: title,
      subtitle: subtitle,
      sessions: sessions,
      category: category,
      price: price,
      oldPrice: oldPrice,
      imageAsset: imageAsset,
      capacity: capacity,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
