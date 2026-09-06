
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/admin/admins_screen.dart';
import '../screens/admin/ads_screen.dart';
import '../screens/admin/booking_requests_screen.dart';
import '../screens/admin/chat_screen.dart';
import '../screens/admin/course_pricing_screen.dart';
import '../screens/admin/customers_screen.dart';
import '../screens/admin/exams_screen.dart';
import '../screens/admin/portfolio_approval_screen.dart';
import '../screens/admin/reports_screen.dart';
import '../screens/admin/settings_screen.dart';
import '../screens/admin/students_screen.dart';
import '../screens/admin/teachers_screen.dart';
import '../screens/common/beauty_hub_screen.dart';
import '../screens/common/certificate_screen.dart';
import '../screens/common/color_lab_screen.dart';
import '../screens/common/courses_screen.dart';
import '../screens/common/exam_overview_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/common/portfolio_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/schedule_screen.dart';
import '../screens/teacher/portfolio_review_screen.dart';
import '../services/current_user.dart';
import '../services/customer_session_service.dart';
import '../services/session_service.dart';

/// فونت انگلیسی لوکس برای Wordmark برند (فقط برای متن لاتین "ERFAN OXIGEN").
TextStyle brandWordmarkFont({required double fontSize, required FontWeight fontWeight, double? letterSpacing, Color? color}) {
  return GoogleFonts.cinzel(fontSize: fontSize, fontWeight: fontWeight, letterSpacing: letterSpacing, color: color);
}

class AppTheme {
  // پالت دقیق Stitch — Erfan Oxigen Ultra-Luxury
  static const Color background = Color(0xFF08090B); // Obsidian
  static const Color background2 = Color(0xFF0D1420); // Deep Navy
  static const Color surface = Color(0xFF0D1420); // Deep Navy
  static const Color surface2 = Color(0xFF171B22); // Graphite
  static const Color surface3 = Color(0xFF22262D); // Surface Container Highest
  static const Color gold = Color(0xFFD4AF5A); // Champagne Gold
  static const Color gold2 = Color(0xFFF1D58A); // Soft Gold
  static const Color champagne = Color(0xFFF1D58A);
  static const Color bronze = Color(0xFFC89B3C); // Champagne Metal Start
  static const Color cream = Color(0xFFF4F0E8); // Warm Ivory
  static const Color muted = Color(0xFFA9ADB4); // Muted Silver
  static const Color success = Color(0xFF34D399);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF6FAEFF);
  static const Color violet = Color(0xFFAD8FFF);
  static const Color steel = Color(0xFF7D8BA0);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
    ).copyWith(
      primary: gold,
      secondary: champagne,
      tertiary: violet,
      surface: surface,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      textTheme: GoogleFonts.vazirmatnTextTheme(ThemeData(brightness: Brightness.dark).textTheme)
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: .055)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: .035),
        hintStyle: const TextStyle(color: Colors.white30),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: gold, width: 1.25),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: gold.withValues(alpha: .22)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: .06)),
    );
  }

  static BoxDecoration glass({double radius = 24, bool strong = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.lerp(surface2, gold, strong ? .10 : .06)!.withValues(alpha: strong ? .92 : .82),
          Color.lerp(surface, gold, .02)!.withValues(alpha: .78),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: gold.withValues(alpha: strong ? .28 : .16)),
      boxShadow: [
        const BoxShadow(color: Color(0x8A000000), blurRadius: 30, offset: Offset(0, 16)),
        if (strong) BoxShadow(color: gold.withValues(alpha: .08), blurRadius: 22, offset: const Offset(0, 6)),
      ],
    );
  }

  static BoxDecoration goldGlow({double radius = 24}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gold2, gold, bronze],
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(color: Color(0x55E9B95F), blurRadius: 26, spreadRadius: -6, offset: Offset(0, 10)),
      ],
    );
  }

  static BoxDecoration heroPanel({double radius = 30}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF1B160E), Color(0xE60B1017), Color(0xFF07090D)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Color(0x3EE9B95F)),
      boxShadow: const [
        BoxShadow(color: Color(0x79000000), blurRadius: 34, offset: Offset(0, 22)),
      ],
    );
  }

  static BoxDecoration outlineGold({double radius = 18}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: gold.withValues(alpha: .32)),
      gradient: LinearGradient(
        colors: [gold.withValues(alpha: .11), Colors.transparent],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    );
  }
}

class OxygenLogoMark extends StatelessWidget {
  final double size;
  final bool animated;

  const OxygenLogoMark({super.key, this.size = 82, this.animated = false});

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/oxigen_shield_mark.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
    if (!animated) return mark;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .96, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: mark,
    );
  }
}

class OxygenBrand extends StatelessWidget {
  final double iconSize;
  final bool compact;

  const OxygenBrand({super.key, this.iconSize = 48, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OxygenLogoMark(size: iconSize),
        SizedBox(width: compact ? 10 : 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ERFAN OXIGEN', style: brandWordmarkFont(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: Colors.white)),
            if (!compact) const Text('BARBER • ACADEMY • STUDIO', style: TextStyle(color: AppTheme.gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
          ],
        ),
      ],
    );
  }
}

class OxygenPage extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showDrawer;

  const OxygenPage({super.key, required this.title, required this.child, this.actions, this.floatingActionButton, this.showDrawer = true});

  @override
  State<OxygenPage> createState() => _OxygenPageState();
}

class _OxygenPageState extends State<OxygenPage> with SingleTickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 560))..forward();

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: widget.showDrawer ? const OxygenSidePanel() : null,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: widget.showDrawer
            ? Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu_rounded)))
            : null,
        title: Row(
          children: [
            const OxygenLogoMark(size: 26),
            const SizedBox(width: 8),
            Flexible(child: Text(widget.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900))),
          ],
        ),
        actions: widget.actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.transparent, AppTheme.gold.withValues(alpha: .35), Colors.transparent]),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AmbientPainter(MediaQuery.sizeOf(context)))),
          SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .02), end: Offset.zero).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic)),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final Size size;
  const _AmbientPainter(this.size);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = RadialGradient(colors: [AppTheme.gold.withValues(alpha: .045), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width * .88, size.height * .02), radius: size.width * .6));
    canvas.drawRect(Offset.zero & size, paint);
    final paint2 = Paint()..shader = RadialGradient(colors: [AppTheme.violet.withValues(alpha: .028), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width * .08, size.height * .85), radius: size.width * .5));
    canvas.drawRect(Offset.zero & size, paint2);
  }
  @override
  bool shouldRepaint(covariant _AmbientPainter oldDelegate) => false;
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTitle({super.key, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5, height: 1.35)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(width: 30, height: 3, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.gold2, AppTheme.gold]), borderRadius: BorderRadius.circular(99))),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? trend;
  const StatTile({super.key, required this.label, required this.value, required this.icon, this.trend});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 20, strong: true),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: AppTheme.goldGlow(radius: 14), child: Icon(icon, color: Colors.black, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 9.5, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))])),
        if (trend != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .08), borderRadius: BorderRadius.circular(99)), child: Text(trend!, style: const TextStyle(color: AppTheme.gold, fontSize: 7.5, fontWeight: FontWeight.w900))),
      ]),
    );
  }
}

class _DrawerItem {
  final String label;
  final IconData icon;
  final Widget? page;
  final bool isLogout;
  const _DrawerItem(this.label, this.icon, this.page, {this.isLogout = false});
}

class OxygenSidePanel extends StatelessWidget {
  const OxygenSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final role = CurrentUser.user?.role ?? 'customer';
    final items = <_DrawerItem>[
      const _DrawerItem('خانه / داشبورد', Icons.dashboard_rounded, null),
      if (role == 'admin') ...[
        const _DrawerItem('مدیران', Icons.admin_panel_settings_rounded, AdminsScreen()),
        const _DrawerItem('درخواست‌های نوبت', Icons.event_available_rounded, BookingRequestsScreen()),
        const _DrawerItem('مدرس‌ها', Icons.school_rounded, TeachersScreen()),
        const _DrawerItem('هنرجوها', Icons.groups_rounded, StudentsScreen()),
        const _DrawerItem('مشتری‌ها', Icons.person_search_rounded, CustomersScreen()),
        const _DrawerItem('آزمون و نمره', Icons.assignment_rounded, ExamsScreen()),
        const _DrawerItem('تأیید نمونه‌کارها', Icons.fact_check_rounded, PortfolioApprovalScreen()),
        const _DrawerItem('چت‌ها', Icons.forum_rounded, ChatScreen()),
        const _DrawerItem('برنامه کلاس‌ها', Icons.calendar_month_rounded, ScheduleScreen()),
        const _DrawerItem('Beauty Studio', Icons.auto_awesome_rounded, BeautyHubScreen()),
        const _DrawerItem('قیمت دوره‌ها', Icons.sell_rounded, CoursePricingScreen()),
        const _DrawerItem('تبلیغات', Icons.campaign_rounded, AdsScreen()),
        const _DrawerItem('گزارش‌ها', Icons.insights_rounded, ReportsScreen()),
        const _DrawerItem('تنظیمات', Icons.tune_rounded, SettingsScreen()),
      ] else if (role == 'teacher') ...[
        const _DrawerItem('برنامه کلاس‌ها', Icons.calendar_month_rounded, ScheduleScreen()),
        const _DrawerItem('هنرجوها', Icons.groups_rounded, StudentsScreen()),
        const _DrawerItem('آزمون‌ها', Icons.assignment_rounded, ExamOverviewScreen(title: 'آزمون‌های من', teacherView: true)),
        const _DrawerItem('Beauty Studio', Icons.auto_awesome_rounded, BeautyHubScreen()),
        const _DrawerItem('Color Lab', Icons.palette_rounded, ColorLabScreen()),
        const _DrawerItem('بررسی نمونه‌کارها', Icons.rate_review_rounded, PortfolioReviewScreen()),        const _DrawerItem('دوره‌ها', Icons.play_lesson_rounded, CoursesScreen()),
        const _DrawerItem('گواهی‌ها', Icons.workspace_premium_rounded, CertificateScreen()),
        const _DrawerItem('اعلان‌ها', Icons.notifications_rounded, NotificationsScreen()),
        const _DrawerItem('چت', Icons.forum_rounded, ChatScreen()),
        const _DrawerItem('پروفایل', Icons.person_rounded, ProfileScreen()),
      ] else if (role == 'student') ...[
        const _DrawerItem('برنامه کلاس‌ها', Icons.calendar_month_rounded, ScheduleScreen()),
        const _DrawerItem('آزمون‌ها', Icons.assignment_rounded, ExamOverviewScreen(title: 'آزمون‌های من', studentView: true)),
        const _DrawerItem('Beauty Studio', Icons.auto_awesome_rounded, BeautyHubScreen()),
        const _DrawerItem('Color Lab', Icons.palette_rounded, ColorLabScreen()),
        const _DrawerItem('نمونه‌کارهای من', Icons.photo_library_rounded, PortfolioScreen()),
        const _DrawerItem('دوره‌ها', Icons.play_lesson_rounded, CoursesScreen()),
        const _DrawerItem('گواهی‌ها', Icons.workspace_premium_rounded, CertificateScreen()),
        const _DrawerItem('اعلان‌ها', Icons.notifications_rounded, NotificationsScreen()),
        const _DrawerItem('چت', Icons.forum_rounded, ChatScreen()),
        const _DrawerItem('پروفایل', Icons.person_rounded, ProfileScreen()),
      ] else ...[
        const _DrawerItem('Beauty Studio', Icons.auto_awesome_rounded, BeautyHubScreen()),
        const _DrawerItem('نوبت‌ها', Icons.event_available_rounded, ScheduleScreen()),
        const _DrawerItem('اعلان‌ها', Icons.notifications_rounded, NotificationsScreen()),
        const _DrawerItem('چت با آرایشگر', Icons.chat_bubble_rounded, ChatScreen()),
        const _DrawerItem('پروفایل', Icons.person_rounded, ProfileScreen()),
      ],
      const _DrawerItem('خروج از حساب', Icons.logout_rounded, null, isLogout: true),
    ];

    return Drawer(
      width: 320,
      backgroundColor: AppTheme.background2,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.heroPanel(radius: 24),
              child: Row(children: [
                const OxygenLogoMark(size: 56, animated: true),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ERFAN OXIGEN', style: brandWordmarkFont(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Colors.white)), const SizedBox(height: 4), const Text('BARBER • ACADEMY • STUDIO', style: TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 1.1))])),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: AppTheme.glass(radius: 14),
                child: Row(children: [
                  Icon(role == 'customer' ? Icons.person_rounded : Icons.verified_user_rounded, color: AppTheme.gold, size: 17),
                  const SizedBox(width: 8),
                  Expanded(child: Text(CurrentUser.name.isEmpty ? 'مهمان' : CurrentUser.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
                  Text(_roleLabel(role), style: const TextStyle(color: AppTheme.muted, fontSize: 9)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(12, 8, 12, 14), itemCount: items.length, separatorBuilder: (_, index) => const SizedBox(height: 5), itemBuilder: (context, index) => _DrawerTile(item: items[index]))),
            const Padding(padding: EdgeInsets.fromLTRB(16, 4, 16, 16), child: Text('More Than A Haircut • It’s A Lifestyle', style: TextStyle(color: Colors.white24, fontSize: 8.5, letterSpacing: .8))),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'admin' => 'مدیر',
        'teacher' => 'مدرس',
        'student' => 'هنرجو',
        'customer' => 'مشتری',
        _ => 'کاربر',
      };
}

class _DrawerTile extends StatefulWidget {
  final _DrawerItem item;
  const _DrawerTile({required this.item});
  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) async {
        setState(() => pressed = false);
        if (item.isLogout) {
          if (CustomerSessionService.customer != null) {
            await CustomerSessionService.logout();
          } else {
            await SessionService.logout();
          }
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          return;
        }
        if (item.page == null) {
          Navigator.pop(context);
          return;
        }
        Navigator.pop(context);
        if (!context.mounted) return;
        await Navigator.push(context, MaterialPageRoute(builder: (_) => item.page!));
      },
      child: AnimatedScale(
        scale: pressed ? .985 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              item.isLogout ? AppTheme.danger.withValues(alpha: .08) : Colors.white.withValues(alpha: .025),
              Colors.transparent,
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.isLogout ? AppTheme.danger.withValues(alpha: .14) : Colors.white.withValues(alpha: .045)),
          ),
          child: Row(children: [Icon(item.icon, size: 19, color: item.isLogout ? AppTheme.danger : AppTheme.gold), const SizedBox(width: 11), Expanded(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: item.isLogout ? AppTheme.danger : Colors.white))), if (!item.isLogout) const Icon(Icons.chevron_left_rounded, size: 17, color: Colors.white24)]),
        ),
      ),
    );
  }
}

class OxygenAnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  const OxygenAnimatedLogo({super.key, this.size = 132, this.showText = true});
  @override
  State<OxygenAnimatedLogo> createState() => _OxygenAnimatedLogoState();
}

class _OxygenAnimatedLogoState extends State<OxygenAnimatedLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _controller, builder: (context, child) => Transform.rotate(angle: _controller.value * .14, child: child), child: OxygenLogoMark(size: widget.size, animated: true)),
      if (widget.showText) ...[
        const SizedBox(height: 12),
        Text('ERFAN OXIGEN', style: brandWordmarkFont(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: 2.6, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('BARBER • ACADEMY • STUDIO', style: TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ],
    ]);
  }
}

class PremiumHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? accentColor;
  const PremiumHero({super.key, required this.eyebrow, required this.title, required this.subtitle, this.actionLabel, this.onAction, this.icon, this.accentColor});
  @override
  Widget build(BuildContext context) {
    final tint = accentColor ?? AppTheme.gold;
    return Container(
      height: 288,
      decoration: AppTheme.heroPanel(radius: 30),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        if (icon != null)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tint.withValues(alpha: .22), const Color(0xFF0B0D11)]),
            ),
            child: Stack(children: [
              Positioned(right: -20, top: -10, child: Opacity(opacity: .5, child: Icon(icon, size: 200, color: tint.withValues(alpha: .18)))),
              Positioned(left: -30, bottom: -30, child: Opacity(opacity: .14, child: Image.asset('assets/images/oxigen_shield_mark.png', width: 200, filterQuality: FilterQuality.high))),
            ]),
          )
        else
          Image.asset('assets/images/login_hero.png', fit: BoxFit.cover, alignment: Alignment.center),
        DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Colors.black.withValues(alpha: .06), Colors.black.withValues(alpha: .54), AppTheme.background.withValues(alpha: .98)]))),
        Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: AppTheme.outlineGold(radius: 99), child: Text(eyebrow, style: const TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 1.1)))),
        Positioned(left: 18, right: 18, bottom: 18, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.03)), const SizedBox(height: 7), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 11.5)), if (actionLabel != null && onAction != null) ...[const SizedBox(height: 12), SizedBox(height: 44, child: ElevatedButton.icon(onPressed: onAction, icon: const Icon(Icons.arrow_forward_rounded, size: 17), label: Text(actionLabel!)))]])),
          const SizedBox(width: 12),
          Container(width: 62, height: 62, decoration: AppTheme.goldGlow(radius: 20), child: Icon(icon ?? Icons.content_cut_rounded, color: Colors.black, size: 30)),
        ])),
      ]),
    );
  }
}

class ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  const ActionCard({super.key, required this.title, required this.subtitle, required this.icon, this.badge, required this.onTap});
  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) { setState(() => pressed = false); widget.onTap(); },
      child: AnimatedScale(
        scale: pressed ? .965 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: AppTheme.glass(radius: 22, strong: true),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Container(width: 46, height: 46, decoration: AppTheme.goldGlow(radius: 15), child: Icon(widget.icon, color: Colors.black, size: 23)), const Spacer(), if (widget.badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .09), borderRadius: BorderRadius.circular(99)), child: Text(widget.badge!, style: const TextStyle(color: AppTheme.gold, fontSize: 7.5, fontWeight: FontWeight.w900))) ]),
            const Spacer(),
            Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5)),
            const SizedBox(height: 4),
            Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5, height: 1.25)),
          ]),
        ),
      ),
    );
  }
}

class BeautyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const BeautyChip({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), decoration: AppTheme.outlineGold(radius: 15), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.circle, size: 5, color: AppTheme.gold), const SizedBox(width: 6), Icon(icon, size: 15, color: Colors.white70), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))]));
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const GlassIconButton({super.key, required this.icon, required this.onTap, this.tooltip});
  @override
  Widget build(BuildContext context) => Tooltip(message: tooltip ?? '', child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Container(width: 44, height: 44, decoration: AppTheme.glass(radius: 14), child: Icon(icon, color: Colors.white70, size: 20))));
}
