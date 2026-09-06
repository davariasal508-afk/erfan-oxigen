import 'package:flutter/material.dart';

import '../../models/portfolio_model.dart';
import '../../services/course_catalog_service.dart';
import '../../services/course_enrollment_service.dart';
import '../../services/current_user.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';
import 'color_lab_screen.dart';

class BeautyHubScreen extends StatefulWidget {
  const BeautyHubScreen({super.key});

  @override
  State<BeautyHubScreen> createState() => _BeautyHubScreenState();
}

class _BeautyHubScreenState extends State<BeautyHubScreen> {
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

  bool get _canEnroll => CurrentUser.role == 'student' || CurrentUser.role == 'teacher';

  Future<void> _enroll(CourseCatalogItem course) async {
    final ok = await CourseEnrollmentService.enroll(course.id, CurrentUser.phone);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ظرفیت این دوره تکمیل شده است.')),
      );
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ثبت‌نام شما در ${course.title} انجام شد.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = [
      ('Fade Lab', 'فید، سایه و ساخت فرم', Icons.content_cut_rounded),
      ('Beard Lab', 'طراحی و فرم‌دهی ریش', Icons.face_rounded),
      ('Color for Men', 'فرمول رنگ موی مردانه', Icons.palette_outlined),
      ('Classic Cut', 'کات کلاسیک و قیچی‌کاری', Icons.content_cut_rounded),
    ];

    final formulas = [
      ('Ash Smoke', 'دودی خاکستری • تون سرد', '8.1 + 9.0', Colors.blueAccent),
      ('Mocha Brown', 'قهوه‌ای موکا • براق', '5.7 + 6.1', AppTheme.gold),
      ('Graphite', 'خاکستری گرافیتی • استایل مردانه', '7.1 + 8.0', AppTheme.bronze),
    ];

    return OxygenPage(
      title: 'Beauty Studio',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          const _BeautyHero(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppTheme.glass(radius: 18, strong: true),
            child: Row(
              children: [
                const OxygenLogoMark(size: 38),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Men’s Grooming Studio • دوره، ظرفیت واقعی و ثبت‌نام آنلاین',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: AppTheme.outlineGold(radius: 10),
                  child: const Text('LIVE', style: TextStyle(color: AppTheme.gold, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              BeautyChip(icon: Icons.palette_outlined, label: 'رنگ و مش'),
              BeautyChip(icon: Icons.content_cut_rounded, label: 'کات و فید'),
              BeautyChip(icon: Icons.auto_awesome_rounded, label: 'استایل'),
              BeautyChip(icon: Icons.camera_alt_outlined, label: 'Lookbook'),
            ],
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'استودیوهای تخصصی', subtitle: 'انتخاب کن، الهام بگیر و مهارتت را حرفه‌ای کن.'),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 720 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 146,
                ),
                itemBuilder: (context, index) {
                  final item = services[index];
                  return ActionCard(
                    title: item.$1,
                    subtitle: item.$2,
                    icon: item.$3,
                    badge: 'PRO',
                    onTap: () => _showService(context, item.$1, item.$2),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'دوره‌های ویژه', subtitle: 'قیمت، تصویر، ظرفیت و متن دوره زیر نظر مدیر مدیریت می‌شود.'),
          const SizedBox(height: 12),
          if (!_ready)
            const SizedBox(height: 220, child: Center(child: CircularProgressIndicator(color: AppTheme.gold)))
          else
            ...CourseCatalogService.items.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CourseCard(
                  course: course,
                  price: _price(course.price),
                  canEnroll: _canEnroll,
                  enrolled: CourseEnrollmentService.isEnrolled(course.id, CurrentUser.phone),
                  enrolledCount: CourseEnrollmentService.count(course.id),
                  onEnroll: () => _enroll(course),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const SectionTitle(title: 'Color Lab', subtitle: 'فرمول‌های الهام‌بخش برای نمونه‌کار و کلاس'),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorLabScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.goldGlow(radius: 20),
              child: Row(
                children: const [
                  Icon(Icons.palette_rounded, color: Colors.black, size: 26),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('باز کردن Color Lab', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15)),
                        SizedBox(height: 3),
                        Text('چرخ رنگ، اسلایدر فرمول و ذخیره‌سازی واقعی', style: TextStyle(color: Colors.black87, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_back_ios_rounded, color: Colors.black, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...formulas.map(
            (formula) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glass(radius: 20, strong: true),
              child: Row(
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: formula.$4.withValues(alpha: .18), borderRadius: BorderRadius.circular(16), border: Border.all(color: formula.$4.withValues(alpha: .5))), child: Icon(Icons.colorize_rounded, color: formula.$4)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(formula.$1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(formula.$2, style: const TextStyle(color: AppTheme.muted, fontSize: 12))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Text(formula.$3, style: const TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SectionTitle(title: 'Lookbook', subtitle: 'نمونه‌کارهای واقعی تأییدشده'),
          const SizedBox(height: 12),
          _LookbookGrid(items: PortfolioService.decidedByManager()),
        ],
      ),
    );
  }

  void _showService(BuildContext context, String title, String subtitle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.muted, height: 1.4)),
            const SizedBox(height: 18),
            const Row(children: [Expanded(child: StatTile(label: 'جلسه', value: '۶', icon: Icons.school_rounded)), SizedBox(width: 10), Expanded(child: StatTile(label: 'سطح', value: 'PRO', icon: Icons.workspace_premium_rounded))]),
          ],
        ),
      ),
    );
  }
}

class _BeautyHero extends StatefulWidget {
  const _BeautyHero();

  @override
  State<_BeautyHero> createState() => _BeautyHeroState();
}

class _BeautyHeroState extends State<_BeautyHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shift = (_controller.value - .5) * 18;
        return Container(
          height: 300,
          decoration: AppTheme.heroPanel(radius: 32),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(shift, 0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF241733), Color(0xFF120A1A)],
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        left: -40,
                        bottom: -30,
                        child: Opacity(
                          opacity: .18,
                          child: Image.asset('assets/images/oxigen_shield_mark.png', width: 240, filterQuality: FilterQuality.high),
                        ),
                      ),
                      const Positioned(right: 24, top: 40, child: Icon(Icons.palette_rounded, color: AppTheme.violet, size: 46)),
                      Positioned(right: 90, top: 90, child: Icon(Icons.brush_rounded, color: AppTheme.gold.withValues(alpha: .5), size: 30)),
                    ],
                  ),
                ),
              ),
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Colors.black.withValues(alpha: .08), Colors.black.withValues(alpha: .70), AppTheme.background.withValues(alpha: .99)]))),
              const Positioned(top: 18, left: 18, child: OxygenLogoMark(size: 50)),
              Positioned(right: 20, left: 20, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('BEAUTY STUDIO', style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2.0)), const SizedBox(height: 7), const Text('یک تجربه واقعی،\nنه فقط یک صفحه.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.02)), const SizedBox(height: 8), Text('دوره‌های ظرفیت‌دار • ثبت‌نام • Fade Lab • Beard Lab • Lookbook', style: TextStyle(color: Colors.white.withValues(alpha: .76), fontSize: 11))])),
            ],
          ),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseCatalogItem course;
  final String price;
  final bool canEnroll;
  final bool enrolled;
  final int enrolledCount;
  final VoidCallback onEnroll;

  const _CourseCard({required this.course, required this.price, required this.canEnroll, required this.enrolled, required this.enrolledCount, required this.onEnroll});

  static Color _accentColor(String accent) => switch (accent) {
        'bronze' => AppTheme.bronze,
        'cream' => AppTheme.gold2,
        _ => AppTheme.gold,
      };

  @override
  Widget build(BuildContext context) {
    final remaining = (course.capacity - enrolledCount).clamp(0, course.capacity);
    return Container(
      decoration: AppTheme.glass(radius: 26, strong: true),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 188,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CourseImage(source: course.imageAsset, accent: _accentColor(course.accent)),
                DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppTheme.background.withValues(alpha: .94)]))),
                Positioned(top: 14, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black.withValues(alpha: .42), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white12)), child: Text(course.category, style: const TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.w900)))),
                Positioned(left: 16, right: 16, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(course.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11))])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(price, style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${course.sessions} • ظرفیت ${course.capacity} نفر', style: const TextStyle(color: AppTheme.muted, fontSize: 10.5))])), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: remaining <= 1 ? AppTheme.danger.withValues(alpha: .10) : AppTheme.success.withValues(alpha: .10), borderRadius: BorderRadius.circular(999)), child: Text(remaining == 0 ? 'تکمیل' : '$remaining جای خالی', style: TextStyle(color: remaining <= 1 ? AppTheme.danger : AppTheme.success, fontSize: 9, fontWeight: FontWeight.w900)))]),
                if (canEnroll) ...[
                  const SizedBox(height: 12),
                  SizedBox(height: 48, child: ElevatedButton.icon(onPressed: enrolled || remaining == 0 ? null : onEnroll, icon: Icon(enrolled ? Icons.check_circle_rounded : Icons.how_to_reg_rounded), label: Text(enrolled ? 'ثبت‌نام شما ثبت شده' : remaining == 0 ? 'ظرفیت تکمیل است' : 'ثبت‌نام در دوره'))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LookbookGrid extends StatefulWidget {
  final List<PortfolioModel> items;
  const _LookbookGrid({required this.items});

  @override
  State<_LookbookGrid> createState() => _LookbookGridState();
}

class _LookbookGridState extends State<_LookbookGrid> {
  bool _recentOnly = false;

  @override
  Widget build(BuildContext context) {
    final list = _recentOnly ? widget.items.take(4).toList() : widget.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(label: const Text('همه'), selected: !_recentOnly, onSelected: (_) => setState(() => _recentOnly = false)),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('اخیر'), selected: _recentOnly, onSelected: (_) => setState(() => _recentOnly = true)),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            decoration: AppTheme.glass(radius: 22),
            child: const Text('هنوز نمونه‌کار تأییدشده‌ای برای نمایش وجود ندارد.', style: TextStyle(color: AppTheme.muted)),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .82),
            itemBuilder: (context, index) {
              final item = list[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CourseImage(source: item.imagePath),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC000000)]),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                          Text(item.studentName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, color: AppTheme.muted)),
                        ],
                      ),
                    ),
                    if (item.finalScore != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .92), borderRadius: BorderRadius.circular(99)),
                          child: Text(item.finalScore!.toStringAsFixed(1), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.black)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
