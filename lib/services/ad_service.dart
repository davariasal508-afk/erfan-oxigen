import '../models/ad_model.dart';
import 'storage_service.dart';

class AdService {
  static final List<AdModel> ads = [];

  static Future<void> initialize() async {
    final raw = await StorageService.loadAds();
    ads
      ..clear()
      ..addAll(raw.map(AdModel.fromJson));
    if (ads.isEmpty) {
      ads.addAll([
        AdModel(id: 'flash-1', title: 'Masterclass رنگ و مش', description: 'ورکشاپ فشرده بالیاژ و فیس‌فریم', category: 'دوره', oldPrice: 4500000, price: 3150000, discountPercent: 30, endsAt: DateTime.now().add(const Duration(hours: 16)), pinned: true, promoCode: 'OXIGEN30'),
        AdModel(id: 'flash-2', title: 'پک ابزار حرفه‌ای', description: 'مجموعه ابزار مناسب هنرجو و مدرس', category: 'محصول', oldPrice: 2800000, price: 2240000, discountPercent: 20, endsAt: DateTime.now().add(const Duration(days: 2)), promoCode: 'PRO20'),
      ]);
      await save();
    }
  }

  static Future<void> save() => StorageService.saveAds(ads.map((e) => e.toJson()).toList());
}
