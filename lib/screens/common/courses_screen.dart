import 'package:flutter/material.dart';

import '../../services/course_catalog_service.dart';
import '../../services/course_enrollment_service.dart';
import '../../services/current_user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
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

  String _price(int value) {
    final formatted = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$formatted تومان';
  }

  Future<void> _enroll(CourseCatalogItem course) async {
    final ok = await CourseEnrollmentService.enroll(course.id, CurrentUser.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'ثبت‌نام شما در ${course.title} انجام شد.' : 'ظرفیت این دوره تکمیل شده است.')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final canEnroll = CurrentUser.role == 'student' || CurrentUser.role == 'teacher';
    return OxygenPage(
      title: 'دوره‌ها',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          const PremiumHero(
            eyebrow: 'ERFAN OXIGEN • ACADEMY',
            title: 'دوره‌ای را انتخاب کن که امضای تو باشد.',
            subtitle: 'آموزش حرفه‌ای، ظرفیت واقعی، ثبت‌نام و تجربه‌ای یکپارچه در Beauty Studio.',
            icon: Icons.play_lesson_rounded,
            accentColor: AppTheme.info,
          ),
          const SizedBox(height: 18),
          if (!_ready)
            const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: AppTheme.gold)))
          else
            ...CourseCatalogService.items.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CourseCard(
                  course: course,
                  price: _price(course.price),
                  canEnroll: canEnroll,
                  enrolled: CourseEnrollmentService.isEnrolled(course.id, CurrentUser.phone),
                  count: CourseEnrollmentService.count(course.id),
                  onEnroll: () => _enroll(course),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseCatalogItem course;
  final String price;
  final bool canEnroll;
  final bool enrolled;
  final int count;
  final VoidCallback onEnroll;

  const _CourseCard({required this.course, required this.price, required this.canEnroll, required this.enrolled, required this.count, required this.onEnroll});

  @override
  Widget build(BuildContext context) {
    final remaining = (course.capacity - count).clamp(0, course.capacity);
    return Container(
      decoration: AppTheme.glass(radius: 28, strong: true),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CourseImage(source: course.imageAsset),
                DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppTheme.background.withValues(alpha: .94)]))),
                Positioned(top: 14, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .42), borderRadius: BorderRadius.circular(999)), child: Text(course.category, style: const TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.w900)))),
                Positioned(left: 16, right: 16, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(course.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11))])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(price, style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text('$course.sessions • ثبت‌نام $count/${course.capacity}', style: const TextStyle(color: AppTheme.muted, fontSize: 10.5))])), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: remaining == 0 ? AppTheme.danger.withValues(alpha: .10) : AppTheme.success.withValues(alpha: .10), borderRadius: BorderRadius.circular(99)), child: Text(remaining == 0 ? 'تکمیل' : '$remaining جای خالی', style: TextStyle(color: remaining == 0 ? AppTheme.danger : AppTheme.success, fontSize: 9, fontWeight: FontWeight.w900)))]),
                if (canEnroll) ...[
                  const SizedBox(height: 12),
                  SizedBox(height: 48, child: ElevatedButton.icon(onPressed: enrolled || remaining == 0 ? null : onEnroll, icon: Icon(enrolled ? Icons.verified_rounded : Icons.how_to_reg_rounded), label: Text(enrolled ? 'ثبت‌نام شما ثبت شده' : remaining == 0 ? 'ظرفیت تکمیل است' : 'ثبت‌نام در این دوره'))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
