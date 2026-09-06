import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../admin/admin_dashboard.dart';
import '../admin/chat_screen.dart';
import '../common/beauty_hub_screen.dart';
import '../common/certificate_screen.dart';
import '../common/exam_overview_screen.dart';
import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';
import '../common/schedule_screen.dart';
import '../common/portfolio_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../login/login_screen.dart';

class DesignReferenceScreen extends StatelessWidget {
  const DesignReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = <_PreviewSpec>[
      _PreviewSpec('اسپلش', const SplashPreview(), const LoginScreen()),
      _PreviewSpec('ورود', const LoginPreview(), const LoginScreen()),
      _PreviewSpec('داشبورد مشتری', const CustomerPreview(), const CustomerHomeScreen(customerName: 'آرش')),
      _PreviewSpec('منوی اصلی', const MenuPreview(), const AdminDashboard()),
      _PreviewSpec('پروفایل', const ProfilePreview(), const ProfileScreen()),
      _PreviewSpec('Color Lab', const ColorLabPreview(), const BeautyHubScreen()),
      _PreviewSpec('گالری مدل‌ها', const GalleryPreview(), const PortfolioScreen()),
      _PreviewSpec('آزمون‌ها', const ExamsPreview(), const ExamOverviewScreen(title: 'آزمون‌های من')),
      _PreviewSpec('برنامه کلاس‌ها', const SchedulePreview(), const ScheduleScreen()),
      _PreviewSpec('گفتگو', const ChatPreview(), const ChatScreen()),
      _PreviewSpec('گواهینامه', const CertificatePreview(), const CertificateScreen()),
      _PreviewSpec('اعلان‌ها', const NotificationsPreview(), const NotificationsScreen()),
      _PreviewSpec('داشبورد ارشد', const AdminPreview(), const AdminDashboard()),
      _PreviewSpec('داشبورد مدرس', const TeacherPreview(), const TeacherDashboard()),
      _PreviewSpec('داشبورد هنرجو', const StudentPreview(), const StudentDashboard()),
      _PreviewSpec('Beauty Studio', const BeautyPreview(), const BeautyHubScreen()),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF02060C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF02060C),
        title: const Text('ERFAN OXIGEN • Design Preview'),
        actions: [
          IconButton(
            tooltip: 'ورود واقعی',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.login_rounded),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1200
              ? 4
              : constraints.maxWidth >= 780
                  ? 3
                  : constraints.maxWidth >= 520
                      ? 2
                      : 1;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
            itemCount: screens.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: .54,
            ),
            itemBuilder: (context, index) {
              final item = screens[index];
              return _PhoneFrame(spec: item);
            },
          );
        },
      ),
    );
  }
}

class _PreviewSpec {
  final String title;
  final Widget preview;
  final Widget destination;

  const _PreviewSpec(this.title, this.preview, this.destination);
}

class _PhoneFrame extends StatelessWidget {
  final _PreviewSpec spec;
  const _PhoneFrame({required this.spec});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => spec.destination),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF050A11),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.gold.withValues(alpha: .42)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x70000000),
              blurRadius: 26,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: Column(
            children: [
              Expanded(child: spec.preview),
              Container(
                height: 30,
                color: const Color(0xFF050A11),
                alignment: Alignment.center,
                child: Text(
                  spec.title,
                  style: const TextStyle(
                    color: AppTheme.gold2,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _PreviewScaffold({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06101A),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 7),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_rounded, color: AppTheme.gold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Expanded(child: child),
          const _BottomNav(),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final labels = <_NavItem>[
      const _NavItem(Icons.home_rounded, 'خانه', true),
      const _NavItem(Icons.calendar_month_rounded, 'نوبت', false),
      const _NavItem(Icons.chat_bubble_rounded, 'گفتگو', false),
      const _NavItem(Icons.notifications_rounded, 'اعلان', false),
      const _NavItem(Icons.person_rounded, 'پروفایل', false),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 9),
      decoration: const BoxDecoration(
        color: Color(0xE9070D13),
        border: Border(top: BorderSide(color: Color(0x33E8B85B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in labels)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 17, color: item.active ? AppTheme.gold : Colors.white54),
                const SizedBox(height: 2),
                Text(item.label, style: TextStyle(fontSize: 6.5, color: item.active ? AppTheme.gold : Colors.white54)),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(this.icon, this.label, this.active);
}

class SplashPreview extends StatefulWidget {
  const SplashPreview({super.key});
  @override
  State<SplashPreview> createState() => _SplashPreviewState();
}

class _SplashPreviewState extends State<SplashPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF091727), Color(0xFF03070D)],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1 + .035 * (0.5 - (_controller.value - .5).abs()) * 2,
                  child: const OxygenLogoMark(size: 92, animated: true),
                ),
                const SizedBox(height: 12),
                const Text('ERFAN OXIGEN', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const Text('HAIR • BEAUTY • ACADEMY', style: TextStyle(color: AppTheme.gold, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 28),
                SizedBox(
                  width: 66,
                  height: 66,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(value: _controller.value, strokeWidth: 2.5, color: AppTheme.gold),
                      Text('${(_controller.value * 100).round()}%', style: const TextStyle(color: AppTheme.gold2, fontWeight: FontWeight.w900, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('در حال بارگذاری دنیای جدید ...', style: TextStyle(color: Colors.white70, fontSize: 7.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoginPreview extends StatelessWidget {
  const LoginPreview({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF090F17), Color(0xFF02060B)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(13),
        child: Column(
          children: [
            const SizedBox(height: 6),
            const OxygenLogoMark(size: 64, animated: true),
            const SizedBox(height: 6),
            const Text('ERFAN OXIGEN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const Text('ورود به حساب کاربری', style: TextStyle(color: Colors.white70, fontSize: 8)),
            const SizedBox(height: 16),
            _FieldPreview(icon: Icons.phone_rounded, label: 'شماره موبایل', value: '+98'),
            const SizedBox(height: 8),
            _FieldPreview(icon: Icons.lock_rounded, label: 'رمز عبور', value: '••••••••'),
            const SizedBox(height: 10),
            _GoldButton(label: 'ورود به حساب کاربری'),
            const SizedBox(height: 11),
            const Text('حساب نداری؟ ثبت‌نام', style: TextStyle(color: AppTheme.gold, fontSize: 7.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class CustomerPreview extends StatelessWidget {
  const CustomerPreview({super.key});
  @override
  Widget build(BuildContext context) {
    return _PreviewScaffold(
      title: 'سلام آرش',
      trailing: const CircleAvatar(radius: 15, backgroundColor: AppTheme.gold, child: Icon(Icons.person, color: Colors.black, size: 17)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        children: [
          _HeroPreview(title: 'نوبت بعدی شما', subtitle: 'امروز • 16:30 • کلاس فید', icon: Icons.content_cut_rounded),
          const SizedBox(height: 8),
          Row(children: const [Expanded(child: _QuickBox(icon: Icons.event_available_rounded, title: 'نوبت من')), SizedBox(width: 6), Expanded(child: _QuickBox(icon: Icons.chat_bubble_rounded, title: 'چت با آرایشگر')), SizedBox(width: 6), Expanded(child: _QuickBox(icon: Icons.auto_awesome_rounded, title: 'Beauty Studio'))]),
          const SizedBox(height: 8),
          Row(children: const [Expanded(child: _QuickBox(icon: Icons.photo_library_rounded, title: 'نمونه‌کارها')), SizedBox(width: 6), Expanded(child: _QuickBox(icon: Icons.school_rounded, title: 'آموزش‌ها')), SizedBox(width: 6), Expanded(child: _QuickBox(icon: Icons.notifications_rounded, title: 'اعلان‌ها'))]),
          const SizedBox(height: 10),
          _BannerPreview(title: 'پیشنهاد ویژه', subtitle: '20٪ تخفیف خدمات VIP', icon: Icons.local_offer_rounded),
        ],
      ),
    );
  }
}

class MenuPreview extends StatelessWidget {
  const MenuPreview({super.key});
  @override
  Widget build(BuildContext context) {
    final labels = ['داشبورد', 'نوبت‌ها', 'مشتری‌ها', 'هنرجوها', 'مدرس‌ها', 'کاربران مدیر', 'آزمون‌ها', 'برنامه کلاس‌ها', 'Beauty Studio', 'Color Lab', 'نمونه‌کارها', 'اعلان‌ها', 'تنظیمات'];
    return Container(
      color: const Color(0xFF06101A),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        children: [
          Row(children: const [OxygenLogoMark(size: 42, animated: true), SizedBox(width: 8), Expanded(child: Text('Arash\nمدیر سیستم', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)))]),
          const SizedBox(height: 11),
          for (final label in labels) Padding(padding: const EdgeInsets.only(bottom: 5), child: _MenuRow(label: label)),
        ],
      ),
    );
  }
}

class ProfilePreview extends StatelessWidget {
  const ProfilePreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'پروفایل من',
    child: ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const CircleAvatar(radius: 42, backgroundColor: AppTheme.gold, child: Icon(Icons.person_rounded, color: Colors.black, size: 42)),
        const SizedBox(height: 7),
        const Text('Arash Barber', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const Text('مدیر سیستم', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted, fontSize: 8)),
        const SizedBox(height: 10),
        Row(children: const [Expanded(child: _StatBox(value: '42', label: 'کلاس‌ها')), SizedBox(width: 6), Expanded(child: _StatBox(value: '12', label: 'نمونه‌کارها')), SizedBox(width: 6), Expanded(child: _StatBox(value: '8', label: 'مشتری'))]),
        const SizedBox(height: 11),
        const _MedalRow(),
        const SizedBox(height: 10),
        _ProgressPreview(label: 'رضایت مشتریان', value: .85),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;

  const _Pill({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppTheme.gold.withValues(alpha: .16)
            : const Color(0xFF0B1722),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: active
              ? AppTheme.gold.withValues(alpha: .55)
              : Colors.white10,
        ),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? AppTheme.gold2 : Colors.white70,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class ColorLabPreview extends StatelessWidget {
  const ColorLabPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'Color Lab',
    child: ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Row(children: const [Expanded(child: _Pill(label: 'فرمول‌ها', active: true)), SizedBox(width: 5), Expanded(child: _Pill(label: 'ترکیب‌رنگ', active: false))]),
        const SizedBox(height: 9),
        Container(height: 172, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.gold, width: 8), gradient: const SweepGradient(colors: [Color(0xFFFFC107), Color(0xFFF44336), Color(0xFF7C4DFF), Color(0xFF00BCD4), Color(0xFF8BC34A), Color(0xFFFFC107)])), child: const Center(child: CircleAvatar(radius: 52, backgroundColor: Color(0xFF1B2530), child: Icon(Icons.person_rounded, size: 64, color: Colors.white70)))),
        const SizedBox(height: 10),
        _ProgressPreview(label: 'رنگ پایه', value: .4),
        _ProgressPreview(label: 'تن گرم', value: .3),
        _ProgressPreview(label: 'اشباع', value: .2),
        _ProgressPreview(label: 'روشنایی', value: .1),
        const SizedBox(height: 5),
        const _GoldButton(label: 'ذخیره فرمول'),
      ],
    ),
  );
}

class GalleryPreview extends StatelessWidget {
  const GalleryPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'گالری مدل‌ها',
    child: GridView.builder(
      padding: const EdgeInsets.all(9),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: .83),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(color: const Color(0xFF101A24), borderRadius: BorderRadius.circular(11), border: Border.all(color: Colors.white12)),
        child: Column(children: [Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(11)), child: Image.asset('assets/images/login_hero.png', fit: BoxFit.cover, width: double.infinity))), Padding(padding: const EdgeInsets.all(5), child: Row(children: [const Icon(Icons.favorite, color: AppTheme.danger, size: 11), const SizedBox(width: 4), Expanded(child: Text('مدل ${index + 1}', style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800)))]))]),
      ),
    ),
  );
}

class ExamsPreview extends StatelessWidget {
  const ExamsPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'آزمون‌های من',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _ExamRow(icon: Icons.content_cut_rounded, title: 'آزمون اصلاح', meta: '45 سؤال • 30 دقیقه'),
        SizedBox(height: 7),
        _ExamRow(icon: Icons.color_lens_rounded, title: 'آزمون رنگ و مش', meta: '60 سؤال • 45 دقیقه'),
        SizedBox(height: 7),
        _ExamRow(icon: Icons.brush_rounded, title: 'آزمون کوتاهی مو', meta: '30 سؤال • 30 دقیقه'),
        SizedBox(height: 7),
        _ExamRow(icon: Icons.school_rounded, title: 'آزمون مدل‌سازی', meta: '45 سؤال • 45 دقیقه'),
      ],
    ),
  );
}

class SchedulePreview extends StatelessWidget {
  const SchedulePreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'برنامه کلاس‌ها',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _DayStrip(),
        SizedBox(height: 9),
        _ClassRow(time: '10:00 - 12:00', title: 'کلاس کوتاهی', color: AppTheme.violet),
        _ClassRow(time: '14:00 - 16:00', title: 'کلاس رنگ', color: AppTheme.danger),
        _ClassRow(time: '18:00 - 20:00', title: 'مدل‌سازی', color: AppTheme.success),
      ],
    ),
  );
}

class ChatPreview extends StatelessWidget {
  const ChatPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'گفتگو',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _ChatRow(name: 'استاد محمدی', text: 'سلام، نتیجه آزمونت آماده است.', time: '14:30'),
        _ChatRow(name: 'سارا', text: 'ممنون استاد، بررسی می‌کنم.', time: '14:15'),
        _ChatRow(name: 'علی', text: 'فایل تمرین را ارسال کردم.', time: '12:20'),
        _ChatRow(name: 'مدیر', text: 'فرم جلسه امروز ثبت شد.', time: '11:10'),
      ],
    ),
  );
}

class CertificatePreview extends StatelessWidget {
  const CertificatePreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'گواهینامه',
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF0E1821), border: Border.all(color: AppTheme.gold, width: 1.5), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(14),
        child: Column(children: const [OxygenLogoMark(size: 54, animated: true), SizedBox(height: 8), Text('ERFAN OXIGEN', style: TextStyle(color: AppTheme.gold2, fontSize: 16, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('CERTIFICATE OF ACHIEVEMENT', style: TextStyle(color: AppTheme.gold, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1.2)), Spacer(), Text('گواهی می‌شود که', style: TextStyle(color: Colors.white70, fontSize: 8)), SizedBox(height: 6), Text('علی رضایی', style: TextStyle(color: AppTheme.gold2, fontSize: 18, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('دوره حرفه‌ای مردانه را با موفقیت گذرانده است.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 8, height: 1.4)), Spacer(), Icon(Icons.verified_rounded, color: AppTheme.gold, size: 46), SizedBox(height: 8), Text('1403/06/22', style: TextStyle(color: AppTheme.muted, fontSize: 7))]),
      ),
    ),
  );
}

class NotificationsPreview extends StatelessWidget {
  const NotificationsPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'اعلان‌ها',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _NoticeRow(color: AppTheme.gold, title: 'کلاس جدید', text: 'کلاس کوتاهی فردا ساعت 10:00 برگزار می‌شود.'),
        _NoticeRow(color: AppTheme.info, title: 'نوبت مشتری', text: 'یک نوبت جدید برای شما ثبت شد.'),
        _NoticeRow(color: AppTheme.success, title: 'پیام جدید', text: 'شما یک پیام جدید دارید.'),
        _NoticeRow(color: AppTheme.violet, title: 'گواهینامه', text: 'گواهینامه جدید دریافت کردید.'),
      ],
    ),
  );
}

class AdminPreview extends StatelessWidget {
  const AdminPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'داشبورد مدیر',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: [
        const _HeroPreview(title: 'سلام آرش', subtitle: 'اتاق فرمان امروز آماده است', icon: Icons.dashboard_rounded),
        const SizedBox(height: 8),
        Row(children: const [Expanded(child: _StatBox(value: '12', label: 'مدرس')), SizedBox(width: 5), Expanded(child: _StatBox(value: '42', label: 'هنرجو')), SizedBox(width: 5), Expanded(child: _StatBox(value: '128', label: 'مشتری'))]),
        const SizedBox(height: 8),
        const _ControlPreview(title: 'نوبت‌های امروز', icon: Icons.event_available_rounded),
        const _ControlPreview(title: 'درخواست‌های نمره', icon: Icons.fact_check_rounded),
        const _ControlPreview(title: 'چت‌های جدید', icon: Icons.chat_bubble_rounded),
      ],
    ),
  );
}

class TeacherPreview extends StatelessWidget {
  const TeacherPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'مدرس',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _HeroPreview(title: 'سلام استاد محمدی', subtitle: 'کلاس امروز • 14:00', icon: Icons.school_rounded),
        SizedBox(height: 8),
        _ControlPreview(title: 'هنرجوهای من', icon: Icons.groups_rounded),
        _ControlPreview(title: 'آزمون‌ها و ارزیابی', icon: Icons.assignment_rounded),
        _ControlPreview(title: 'پیام‌های جدید', icon: Icons.forum_rounded),
      ],
    ),
  );
}

class StudentPreview extends StatelessWidget {
  const StudentPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'هنرجو',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _HeroPreview(title: 'دوره فید حرفه‌ای', subtitle: '72٪ پیشرفت • آزمون بعدی جمعه', icon: Icons.play_lesson_rounded),
        SizedBox(height: 8),
        _ProgressPreview(label: 'پیشرفت دوره', value: .72),
        SizedBox(height: 8),
        _ControlPreview(title: 'آپلود نمونه‌کار', icon: Icons.upload_file_rounded),
        _ControlPreview(title: 'نمره‌های من', icon: Icons.grade_rounded),
        _ControlPreview(title: 'برنامه کلاس‌ها', icon: Icons.calendar_month_rounded),
      ],
    ),
  );
}

class BeautyPreview extends StatelessWidget {
  const BeautyPreview({super.key});
  @override
  Widget build(BuildContext context) => _PreviewScaffold(
    title: 'Beauty Studio',
    child: ListView(
      padding: const EdgeInsets.all(9),
      children: const [
        _HeroPreview(title: 'Men’s Grooming Studio', subtitle: 'خدمات، دوره‌ها و ظرفیت‌های فعال', icon: Icons.auto_awesome_rounded),
        SizedBox(height: 8),
        _CoursePreview(title: 'کلاس رنگ حرفه‌ای', seats: '6 نفر ظرفیت', price: '4,900,000 تومان'),
        _CoursePreview(title: 'فید پیشرفته', seats: '8 نفر ظرفیت', price: '3,600,000 تومان'),
        _CoursePreview(title: 'گریم مردانه', seats: '5 نفر ظرفیت', price: '2,900,000 تومان'),
      ],
    ),
  );
}

class _FieldPreview extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _FieldPreview({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
    child: Row(children: [Icon(icon, color: AppTheme.gold, size: 14), const SizedBox(width: 7), Expanded(child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 7))), Text(value, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700))]),
  );
}

class _GoldButton extends StatelessWidget {
  final String label;
  const _GoldButton({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.gold2, AppTheme.gold]), borderRadius: BorderRadius.circular(10)), child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)));
}

class _QuickBox extends StatelessWidget {
  final IconData icon;
  final String title;
  const _QuickBox({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Container(height: 69, padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF0B1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: AppTheme.gold, size: 18), const SizedBox(height: 4), Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800))]));
}

class _HeroPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _HeroPreview({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Container(height: 142, padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF18283A), Color(0xFF091019)], begin: Alignment.topRight, end: Alignment.bottomLeft), borderRadius: BorderRadius.circular(13), border: Border.all(color: AppTheme.gold.withValues(alpha: .25))), child: Stack(children: [Positioned(top: 0, right: 0, child: Container(width: 36, height: 36, decoration: AppTheme.goldGlow(radius: 11), child: Icon(icon, color: Colors.black, size: 18))), Positioned(bottom: 2, right: 0, left: 0, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 7.5, height: 1.3))]))]));
}

class _BannerPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _BannerPreview({required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF211810), Color(0xFF111820)]), borderRadius: BorderRadius.circular(11), border: Border.all(color: AppTheme.gold.withValues(alpha: .25))), child: Row(children: [Container(width: 37, height: 37, decoration: AppTheme.goldGlow(radius: 11), child: Icon(icon, color: Colors.black, size: 18)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 6.5))]))]));
}

class _MenuRow extends StatelessWidget {
  final String label;
  const _MenuRow({required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF0B1723), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: Row(children: [const Icon(Icons.chevron_left_rounded, color: Colors.white24, size: 12), const SizedBox(width: 4), Expanded(child: Text(label, textAlign: TextAlign.right, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800))), const Icon(Icons.circle, color: AppTheme.gold, size: 6)]));
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: const Color(0xFF0B1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Column(children: [Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 6.5))]));
}

class _MedalRow extends StatelessWidget {
  const _MedalRow();
  @override
  Widget build(BuildContext context) => Row(children: const [Expanded(child: _Medal(icon: Icons.emoji_events_rounded, title: 'استاد برتر')), SizedBox(width: 5), Expanded(child: _Medal(icon: Icons.workspace_premium_rounded, title: 'مدیر حرفه‌ای')), SizedBox(width: 5), Expanded(child: _Medal(icon: Icons.star_rounded, title: 'رضایت عالی'))]);
}

class _Medal extends StatelessWidget {
  final IconData icon;
  final String title;
  const _Medal({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0B1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.gold.withValues(alpha: .22))), child: Column(children: [Icon(icon, color: AppTheme.gold, size: 21), const SizedBox(height: 3), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800))]));
}

class _ProgressPreview extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressPreview({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(label, style: const TextStyle(fontSize: 7, color: Colors.white70))), Text('${(value * 100).round()}%', style: const TextStyle(fontSize: 7, color: AppTheme.gold))]), const SizedBox(height: 3), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: value, minHeight: 5, color: AppTheme.gold, backgroundColor: Colors.white10))]));
}

class _ControlPreview extends StatelessWidget {
  final String title;
  final IconData icon;
  const _ControlPreview({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white10)), child: Row(children: [Container(width: 29, height: 29, decoration: AppTheme.goldGlow(radius: 9), child: Icon(icon, color: Colors.black, size: 14)), const SizedBox(width: 7), Expanded(child: Text(title, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800))), const Icon(Icons.chevron_left_rounded, color: AppTheme.gold, size: 14)]));
}

class _ExamRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String meta;
  const _ExamRow({required this.icon, required this.title, required this.meta});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF101F2C), shape: BoxShape.circle, border: Border.all(color: AppTheme.gold.withValues(alpha: .22))), child: Icon(icon, color: AppTheme.gold, size: 20)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(meta, style: const TextStyle(color: AppTheme.muted, fontSize: 6.5))])), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: AppTheme.goldGlow(radius: 7), child: const Text('شروع آزمون', style: TextStyle(color: Colors.black, fontSize: 6.5, fontWeight: FontWeight.w900))) ]));
}

class _DayStrip extends StatelessWidget {
  const _DayStrip();
  @override
  Widget build(BuildContext context) => Row(children: [for (final d in ['9', '10', '11', '12', '13']) Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), padding: const EdgeInsets.symmetric(vertical: 7), decoration: BoxDecoration(color: d == '12' ? AppTheme.gold : const Color(0xFF0A1722), borderRadius: BorderRadius.circular(8)), child: Column(children: [Text(d, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: d == '12' ? Colors.black : Colors.white)), const SizedBox(height: 2), Text('آبان', style: TextStyle(fontSize: 5.5, color: d == '12' ? Colors.black54 : AppTheme.muted))]))) ]);
}

class _ClassRow extends StatelessWidget {
  final String time;
  final String title;
  final Color color;
  const _ClassRow({required this.time, required this.title, required this.color});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 3))), child: Row(children: [Icon(Icons.access_time_rounded, color: color, size: 15), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 6.5))])), const Icon(Icons.school_rounded, color: Colors.white38, size: 14)]));
}

class _ChatRow extends StatelessWidget {
  final String name;
  final String text;
  final String time;
  const _ChatRow({required this.name, required this.text, required this.time});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Row(children: [const CircleAvatar(radius: 17, backgroundColor: AppTheme.gold, child: Icon(Icons.person, color: Colors.black, size: 16)), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 6.5))])), Text(time, style: const TextStyle(color: AppTheme.muted, fontSize: 5.5))]));
}

class _NoticeRow extends StatelessWidget {
  final Color color;
  final String title;
  final String text;
  const _NoticeRow({required this.color, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Row(children: [Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: .12), shape: BoxShape.circle), child: Icon(Icons.notifications_rounded, color: color, size: 15)), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 6.5, height: 1.25))]))]));
}

class _CoursePreview extends StatelessWidget {
  final String title;
  final String seats;
  final String price;
  const _CoursePreview({required this.title, required this.seats, required this.price});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0A1722), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.gold.withValues(alpha: .18))), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), image: const DecorationImage(image: AssetImage('assets/images/login_hero.png'), fit: BoxFit.cover))), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(seats, style: const TextStyle(color: AppTheme.success, fontSize: 6.5)), const SizedBox(height: 2), Text(price, style: const TextStyle(color: AppTheme.gold2, fontSize: 7.5, fontWeight: FontWeight.w900))])), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: AppTheme.goldGlow(radius: 7), child: const Text('ثبت‌نام', style: TextStyle(color: Colors.black, fontSize: 6.5, fontWeight: FontWeight.w900))) ]));
}
