import 'package:flutter/material.dart';
import '../../models/ad_model.dart';
import '../../services/ad_service.dart';
import '../../theme/app_theme.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});
  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  @override
  Widget build(BuildContext context) {
    final ads = [...AdService.ads]..sort((a, b) => (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0));
    return OxygenPage(
      title: 'OXIGEN Market',
      floatingActionButton: FloatingActionButton.extended(onPressed: _addAd, icon: const Icon(Icons.campaign_rounded), label: const Text('کمپین جدید')),
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 30), children: [
        const PremiumHero(eyebrow: 'BEAUTY OFFERS • FLASH SALE', title: 'پیشنهادهایی که می‌فروشند.', subtitle: 'دوره، محصول و خدمات را با تخفیف، تایمر و کد اختصاصی مدیریت کن.', icon: Icons.campaign_rounded, accentColor: AppTheme.violet),
        const SizedBox(height: 18),
        ...ads.map(_card),
      ]),
    );
  }

  Widget _card(AdModel ad) {
    final remaining = ad.endsAt.difference(DateTime.now());
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(17), decoration: AppTheme.glass(radius: 22, strong: ad.pinned), child: Column(children: [
      Row(children: [Container(width: 50, height: 50, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.local_offer_rounded, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ad.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(ad.category, style: const TextStyle(color: AppTheme.muted, fontSize: 11))])), if (ad.pinned) const Icon(Icons.push_pin_rounded, color: AppTheme.gold)]),
      const SizedBox(height: 10),
      Text(ad.description, style: const TextStyle(color: AppTheme.muted, height: 1.45)),
      const SizedBox(height: 12),
      Row(children: [if (ad.oldPrice > 0) Text('${ad.oldPrice} تومان', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.white38, fontSize: 11)), const Spacer(), Text('${ad.price} تومان', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.gold))]),
      const SizedBox(height: 10),
      Row(children: [if (ad.discountPercent > 0) Chip(label: Text('${ad.discountPercent}% تخفیف')), const Spacer(), Text(remaining.isNegative ? 'پایان یافته' : 'مانده: ${remaining.inHours} ساعت', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w800, fontSize: 11))]),
      if (ad.promoCode.isNotEmpty) Align(alignment: AlignmentDirectional.centerStart, child: Text('کد: ${ad.promoCode}', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w900, fontSize: 11))),
    ]));
  }

  Future<void> _addAd() async {
    final title = TextEditingController();
    final description = TextEditingController();
    final price = TextEditingController();
    final oldPrice = TextEditingController();
    final discount = TextEditingController();
    final result = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('کمپین جدید'), content: SingleChildScrollView(child: Column(children: [_field(title, 'عنوان'), _field(description, 'توضیحات'), _field(oldPrice, 'قیمت قبل'), _field(price, 'قیمت جدید'), _field(discount, 'درصد تخفیف')])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('ساخت'))]));
    if (result == true && title.text.trim().isNotEmpty) {
      AdService.ads.add(AdModel(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title.text.trim(), description: description.text.trim(), oldPrice: int.tryParse(oldPrice.text) ?? 0, price: int.tryParse(price.text) ?? 0, discountPercent: int.tryParse(discount.text) ?? 0));
      await AdService.save();
      if (mounted) setState(() {});
    }
    title.dispose(); description.dispose(); price.dispose(); oldPrice.dispose(); discount.dispose();
  }

  Widget _field(TextEditingController c, String label) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, decoration: InputDecoration(labelText: label)));
}
