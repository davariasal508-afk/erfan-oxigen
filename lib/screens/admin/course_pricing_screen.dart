import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';
import '../../services/course_catalog_service.dart';
import '../../services/course_enrollment_service.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';

class CoursePricingScreen extends StatefulWidget {
  const CoursePricingScreen({super.key});

  @override
  State<CoursePricingScreen> createState() => _CoursePricingScreenState();
}

class _CoursePricingScreenState extends State<CoursePricingScreen> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await CourseCatalogService.initialize();
    await CourseEnrollmentService.initialize();
    if (mounted) setState(() => _ready = true);
  }

  String _digits(int value) => value.toString().replaceAllMapped(RegExp(r'\d'), (m) {
        const fa = '۰۱۲۳۴۵۶۷۸۹';
        return fa[int.parse(m.group(0)!)];
      });

  String _price(int value) => '${_digits(value)} تومان';

  Future<void> _edit(CourseCatalogItem course) async {
    final title = TextEditingController(text: course.title);
    final subtitle = TextEditingController(text: course.subtitle);
    final sessions = TextEditingController(text: course.sessions);
    final category = TextEditingController(text: course.category);
    final price = TextEditingController(text: course.price.toString());
    final oldPrice = TextEditingController(text: course.oldPrice?.toString() ?? '');
    final capacity = TextEditingController(text: course.capacity.toString());
    String imageAsset = course.imageAsset;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            backgroundColor: AppTheme.surface2,
            title: Text('ویرایش ${course.title}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(height: 150, width: double.infinity, child: CourseImage(source: imageAsset)),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
                      if (picked == null) return;
                      setDialogState(() => imageAsset = picked.path);
                    },
                    icon: const Icon(Icons.image_rounded),
                    label: const Text('تغییر تصویر دوره'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان دوره', prefixIcon: Icon(Icons.title_rounded))),
                  const SizedBox(height: 10),
                  TextField(controller: subtitle, maxLines: 2, decoration: const InputDecoration(labelText: 'توضیح دوره', prefixIcon: Icon(Icons.notes_rounded))),
                  const SizedBox(height: 10),
                  TextField(controller: sessions, decoration: const InputDecoration(labelText: 'جلسات / آزمون‌ها', prefixIcon: Icon(Icons.calendar_month_rounded))),
                  const SizedBox(height: 10),
                  TextField(controller: category, decoration: const InputDecoration(labelText: 'دسته‌بندی', prefixIcon: Icon(Icons.category_rounded))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت فعلی'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: oldPrice, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت قبل'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ظرفیت نفرات', prefixIcon: Icon(Icons.groups_rounded))),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              FilledButton(
                onPressed: () async {
                  final newPrice = int.tryParse(price.text.replaceAll(',', '').trim());
                  final previous = int.tryParse(oldPrice.text.replaceAll(',', '').trim());
                  final seats = int.tryParse(capacity.text.trim());
                  if (newPrice == null || newPrice <= 0 || seats == null || seats <= 0) return;
                  await CourseCatalogService.updateCourse(
                    course.id,
                    title: title.text.trim().isEmpty ? course.title : title.text.trim(),
                    subtitle: subtitle.text.trim().isEmpty ? course.subtitle : subtitle.text.trim(),
                    sessions: sessions.text.trim().isEmpty ? course.sessions : sessions.text.trim(),
                    category: category.text.trim().isEmpty ? course.category : category.text.trim(),
                    price: newPrice,
                    oldPrice: previous,
                    imageAsset: imageAsset,
                    capacity: seats,
                  );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  setState(() {});
                },
                child: const Text('ذخیره تغییرات'),
              ),
            ],
          ),
        );
      },
    );

    title.dispose();
    subtitle.dispose();
    sessions.dispose();
    category.dispose();
    price.dispose();
    oldPrice.dispose();
    capacity.dispose();
  }

  Future<void> _showEnrollments(CourseCatalogItem course) async {
    final phones = CourseEnrollmentService.enrolledPhones(course.id);
    final users = phones.map((phone) {
      try {
        return UserManager.users.firstWhere((user) => user.phone.trim() == phone.trim());
      } catch (_) {
        return null;
      }
    }).whereType<UserModel>().toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface2,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ثبت‌نام‌های ${course.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text('${phones.length} نفر از ${course.capacity} نفر ظرفیت', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
              const SizedBox(height: 14),
              if (users.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('هنوز کسی ثبت‌نام نکرده است.')))
              else
                ...users.map((user) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person_rounded)), title: Text(user.name), subtitle: Text(user.phone), trailing: const Icon(Icons.verified_rounded, color: AppTheme.success))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OxygenPage(
      title: 'Beauty Studio • مدیریت دوره‌ها',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          const PremiumHero(
            eyebrow: 'ADMIN • BEAUTY STUDIO',
            title: 'تصویر، متن، قیمت و ظرفیت؛ همه دست خودت.',
            subtitle: 'هر دوره را شخصی‌سازی کن و همان لحظه دوره برای هنرجو و مدرس با اطلاعات جدید نمایش داده می‌شود.',
            icon: Icons.sell_rounded,
            accentColor: AppTheme.gold,
          ),
          const SizedBox(height: 18),
          if (!_ready)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: AppTheme.gold)))
          else
            ...CourseCatalogService.items.map(
              (course) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: AppTheme.glass(radius: 24, strong: true),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SizedBox(height: 150, width: double.infinity, child: CourseImage(source: course.imageAsset)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), const SizedBox(height: 4), Text(course.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5)), const SizedBox(height: 7), Text('${_price(course.price)} • ظرفیت ${course.capacity}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 11))])),
                          IconButton(onPressed: () => _edit(course), tooltip: 'ویرایش دوره', icon: const Icon(Icons.edit_rounded, color: AppTheme.gold)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _showEnrollments(course), icon: const Icon(Icons.groups_rounded), label: Text('مشاهده ثبت‌نام‌ها • ${CourseEnrollmentService.count(course.id)} نفر'))),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
