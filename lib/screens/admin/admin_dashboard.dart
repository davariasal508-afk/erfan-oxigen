import 'package:flutter/material.dart';

import '../../services/current_user.dart';
import '../../services/exam_service.dart';
import '../../services/booking_service.dart';
import '../../services/course_catalog_service.dart';
import '../../services/customer_service.dart';
import '../../services/session_service.dart';
import '../../services/user_manager.dart';
import '../../services/portfolio_service.dart';
import '../../models/portfolio_model.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_theme.dart';
import '../common/beauty_hub_screen.dart';
import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';
import '../common/schedule_screen.dart';
import 'admins_screen.dart';
import 'ads_screen.dart';
import 'booking_requests_screen.dart';
import 'chat_screen.dart';
import 'course_pricing_screen.dart';
import 'customers_screen.dart';
import 'exams_screen.dart';
import 'portfolio_approval_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'students_screen.dart';
import 'teachers_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    await SessionService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final user = CurrentUser.user;
    final permissions = user?.permissions ?? <String, bool>{};
    final canManageUsers = permissions['manageUsers'] ?? true;
    final canViewStudents = permissions['viewStudents'] ?? true;
    final canSendMessage = permissions['sendMessage'] ?? true;
    final canViewReports = permissions['viewReports'] ?? true;
    final courses = CourseCatalogService.items;
    final schedule = ScheduleService.items.where((e) => e.active).take(3).toList();
    final pendingPortfolio = PortfolioService.pendingForManager();
    final pendingPortfolioCount = pendingPortfolio.length;

    final actions = <Widget>[
      if (canManageUsers)
        ActionCard(title: 'مدرس‌ها', subtitle: 'تیم آموزشی و تخصص‌ها', icon: Icons.school_rounded, badge: 'TEAM', onTap: () => _open(context, const TeachersScreen())),
      if (canViewStudents)
        ActionCard(title: 'هنرجوها', subtitle: 'پروفایل و ارزیابی', icon: Icons.groups_rounded, badge: 'STUDENTS', onTap: () => _open(context, const StudentsScreen())),
      if (canManageUsers)
        ActionCard(title: 'مدیران', subtitle: 'دسترسی و امنیت', icon: Icons.admin_panel_settings_rounded, badge: 'PRO', onTap: () => _open(context, const AdminsScreen())),
      ActionCard(title: 'درخواست‌های نوبت', subtitle: 'تأیید، رد یا تغییر زمان نوبت مشتری', icon: Icons.event_available_rounded, badge: BookingService.pendingForManager().isEmpty ? null : '${BookingService.pendingForManager().length}', onTap: () => _open(context, const BookingRequestsScreen())),
      ActionCard(title: 'مشتری‌ها', subtitle: 'نوبت و ارتباط با مشتری', icon: Icons.person_search_rounded, badge: 'CRM', onTap: () => _open(context, const CustomersScreen())),
      ActionCard(title: 'آزمون و نمره', subtitle: 'ارزیابی و تأیید نهایی', icon: Icons.assignment_rounded, badge: 'GRADE', onTap: () => _open(context, const ExamsScreen())),
      ActionCard(title: 'تأیید نمونه‌کارها', subtitle: 'بررسی نمره مدرس و تأیید نهایی', icon: Icons.fact_check_rounded, badge: 'REVIEW', onTap: () => _open(context, const PortfolioApprovalScreen())),
      if (canSendMessage)
        ActionCard(title: 'چت‌ها', subtitle: 'خصوصی و گروهی', icon: Icons.forum_rounded, badge: 'LIVE', onTap: () => _open(context, const ChatScreen())),
      ActionCard(title: 'برنامه کلاس‌ها', subtitle: 'زمان‌بندی و مشاهده‌ها', icon: Icons.calendar_month_rounded, badge: 'ADMIN', onTap: () => _open(context, const ScheduleScreen())),
      ActionCard(title: 'Men’s Grooming Studio', subtitle: 'دوره، Fade Lab و Lookbook', icon: Icons.auto_awesome_rounded, badge: 'SIGNATURE', onTap: () => _open(context, const BeautyHubScreen())),
      if (canManageUsers)
        ActionCard(title: 'قیمت دوره‌ها', subtitle: 'قیمت و تخفیف دوره‌ها', icon: Icons.sell_rounded, badge: 'CONTROL', onTap: () => _open(context, const CoursePricingScreen())),
      ActionCard(title: 'تبلیغات', subtitle: 'پیشنهاد و Flash Sale', icon: Icons.campaign_rounded, onTap: () => _open(context, const AdsScreen())),
      if (canViewReports)
        ActionCard(title: 'گزارش‌ها', subtitle: 'آمار و عملکرد', icon: Icons.insights_rounded, badge: 'DATA', onTap: () => _open(context, const ReportsScreen())),
      ActionCard(title: 'تنظیمات', subtitle: 'سرور، برند و امنیت', icon: Icons.tune_rounded, onTap: () => _open(context, const SettingsScreen())),
    ];

    return Scaffold(
      drawer: const OxygenSidePanel(),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background.withValues(alpha: .94),
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              title: const OxygenBrand(compact: true, iconSize: 38),
              actions: [
                IconButton(
                  tooltip: 'اعلان‌ها',
                  onPressed: () => _open(context, const NotificationsScreen()),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
                IconButton(
                  tooltip: 'پروفایل',
                  onPressed: () => _open(context, const ProfileScreen()),
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    child: Icon(Icons.person_rounded, size: 18),
                  ),
                ),
                IconButton(
                  tooltip: 'خروج',
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 34),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 6),
                  _WelcomeHero(name: user?.name ?? 'مدیر', onOpenBeauty: () => _open(context, const BeautyHubScreen())),
                  const SizedBox(height: 20),
                  const _SectionHeaderBar(title: 'خلاصه امروز'),
                  const SizedBox(height: 14),
                  _TodaySummary(onOpenBookings: () => _open(context, const BookingRequestsScreen())),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: StatTile(label: 'مدرس‌ها', value: '${UserManager.getUsersByRole('teacher').length}', icon: Icons.school_rounded, trend: 'ACTIVE')),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(label: 'هنرجوها', value: '${UserManager.getUsersByRole('student').length}', icon: Icons.groups_rounded, trend: 'LIVE')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: StatTile(label: 'مشتری‌ها', value: '${CustomerService.customers.where((c) => c.active).length}', icon: Icons.person_search_rounded, trend: 'CRM')),
                      const SizedBox(width: 10),
                      Expanded(child: StatTile(label: 'آزمون‌ها', value: '${ExamService.exams.length}', icon: Icons.assignment_rounded, trend: 'GRADE')),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const SectionTitle(title: 'اتاق فرمان امروز', subtitle: 'مهم‌ترین چیزهایی که همین حالا باید ببینی.'),
                  const SizedBox(height: 12),
                  _ControlStrip(
                    title: 'درخواست‌های نوبت',
                    subtitle: BookingService.pendingForManager().isEmpty
                        ? 'درخواست جدیدی در صف تأیید نیست.'
                        : '${BookingService.pendingForManager().length} درخواست نوبت در انتظار تأیید است.',
                    icon: Icons.event_available_rounded,
                    color: AppTheme.gold,
                    action: 'مدیریت',
                    onTap: () => _open(context, const BookingRequestsScreen()),
                  ),
                  const SizedBox(height: 10),
                  _ControlStrip(
                    title: 'درخواست‌های نمره',
                    subtitle: 'مدرس‌ها می‌توانند نتیجه را برای تأیید ارسال کنند.',
                    icon: Icons.fact_check_rounded,
                    color: AppTheme.violet,
                    action: 'بررسی',
                    onTap: () => _open(context, const ExamsScreen()),
                  ),
                  const SizedBox(height: 10),
                  _ControlStrip(
                    title: 'نمونه‌کارهای در انتظار تأیید',
                    subtitle: pendingPortfolio.isEmpty
                        ? 'در حال حاضر موردی در صف تأیید نیست.'
                        : '$pendingPortfolioCount نمونه‌کار توسط مدرس نمره‌دهی شده و منتظر تأیید نهایی است.',
                    icon: Icons.photo_library_rounded,
                    color: AppTheme.info,
                    action: 'تأیید',
                    onTap: () => _open(context, const PortfolioApprovalScreen()),
                  ),
                  const SizedBox(height: 10),
                  _ControlStrip(
                    title: 'چت‌های جدید',
                    subtitle: 'پیام‌های خصوصی و گروهی در انتظار پاسخ هستند.',
                    icon: Icons.mark_unread_chat_alt_rounded,
                    color: AppTheme.info,
                    action: 'باز کردن',
                    onTap: () => _open(context, const ChatScreen()),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'برنامه استودیو', subtitle: 'برنامه‌ای که کاربران امروز می‌بینند.'),
                  const SizedBox(height: 12),
                  if (schedule.isEmpty)
                    _EmptyPanel(text: 'برای امروز برنامه‌ای ثبت نشده است.', icon: Icons.calendar_month_rounded)
                  else
                    ...schedule.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ScheduleCard(item.day, item.time, item.title, item.room),
                        )),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'Men’s Grooming Studio', subtitle: 'دوره‌های ویترینی با قیمت قابل مدیریت.'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: courses.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) => _CourseShowcase(course: courses[index], onTap: () => _open(context, const BeautyHubScreen())),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'دسترسی‌های اصلی', subtitle: 'ساختار جدید برای یک پنل خلوت‌تر و حرفه‌ای‌تر.'),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 920 ? 4 : constraints.maxWidth >= 560 ? 3 : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: actions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 154,
                        ),
                        itemBuilder: (context, index) => actions[index],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeroGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.gold.withValues(alpha: .05)
      ..strokeWidth = 1;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdminHeroGridPainter oldDelegate) => false;
}

class _SectionHeaderBar extends StatelessWidget {
  final String title;
  const _SectionHeaderBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 30,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: .55), blurRadius: 14)],
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: .2)),
      ],
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final VoidCallback onOpenBookings;
  const _TodaySummary({required this.onOpenBookings});

  @override
  Widget build(BuildContext context) {
    final newBookings = BookingService.items.where((b) => DateTime.now().difference(b.createdAt).inHours < 24).length;
    final pending = BookingService.pendingForManager().length;
    final portfolio = PortfolioService.items;
    final reviewed = portfolio.where((e) => e.status != PortfolioStatus.pendingTeacher).length;
    final reviewPct = portfolio.isEmpty ? 0.0 : reviewed / portfolio.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GlowStatCard(
                label: 'رزروهای جدید',
                value: '$newBookings',
                icon: Icons.event_available_rounded,
                color: AppTheme.gold,
                footnote: '۲۴ ساعت اخیر',
                onTap: onOpenBookings,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlowStatCard(
                label: 'درخواست‌های در انتظار',
                value: '$pending',
                icon: Icons.pending_actions_rounded,
                color: AppTheme.danger,
                footnote: pending == 0 ? 'موردی نیست' : 'نیاز به بررسی',
                onTap: onOpenBookings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppTheme.surface2, AppTheme.surface]),
            border: Border.all(color: AppTheme.gold.withValues(alpha: .15)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.gold.withValues(alpha: .10), Colors.transparent])),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('نمونه‌کارهای ارسالی هنرجویان', style: TextStyle(color: AppTheme.muted, fontSize: 13, fontWeight: FontWeight.w600)),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.surface2, border: Border.all(color: AppTheme.gold.withValues(alpha: .3))),
                        child: const Icon(Icons.upload_file_rounded, color: AppTheme.gold, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text('${portfolio.length}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 18),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: reviewPct,
                            minHeight: 10,
                            backgroundColor: Colors.black.withValues(alpha: .4),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('${(reviewPct * 100).round()}٪ بررسی شده', style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlowStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String footnote;
  final VoidCallback onTap;
  const _GlowStatCard({required this.label, required this.value, required this.icon, required this.color, required this.footnote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppTheme.surface2, AppTheme.surface]),
          border: Border.all(color: color.withValues(alpha: .2)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -22,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: .16), Colors.transparent])),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12.5, fontWeight: FontWeight.w600))),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.surface2, border: Border.all(color: color.withValues(alpha: .3))),
                      child: Icon(icon, color: color, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(footnote, style: TextStyle(color: color.withValues(alpha: .85), fontSize: 10.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  final String name;
  final VoidCallback onOpenBeauty;

  const _WelcomeHero({required this.name, required this.onOpenBeauty});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: AppTheme.heroPanel(radius: 32),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B160E), Color(0xFF0B0D11)],
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: -20,
            child: Opacity(
              opacity: .16,
              child: Image.asset('assets/images/oxigen_shield_mark.png', width: 260, filterQuality: FilterQuality.high),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _AdminHeroGridPainter())),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.black.withValues(alpha: .08),
                  Colors.black.withValues(alpha: .44),
                  AppTheme.background.withValues(alpha: .99),
                ],
                stops: const [0, .45, 1],
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.gold.withValues(alpha: .28)),
              ),
              child: const Text('CONTROL CENTER • PREMIUM', style: TextStyle(color: AppTheme.gold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
            ),
          ),
          Positioned(
            right: 18,
            left: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سلام $name', style: const TextStyle(color: AppTheme.gold2, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('این بار فقط مدیریت نیست؛\nتجربه‌ی ERFAN OXIGEN است.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, height: 1.02)),
                const SizedBox(height: 9),
                const Text('نوبت‌ها، کلاس‌ها، آزمون‌ها، چت‌ها، مشتری‌ها و Men’s Grooming Studio را از یک مرکز فرمان کنترل کن.', style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 11.5)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onOpenBeauty,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                    label: const Text('ورود به Men’s Grooming Studio'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlStrip extends StatelessWidget {
  final String title;
  final String subtitle;
  final String action;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlStrip({required this.title, required this.subtitle, required this.action, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: AppTheme.glass(radius: 22, strong: true),
          child: Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: .3))), child: Icon(icon, color: color, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 4), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5, height: 1.35))])),
              const SizedBox(width: 10),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(12)), child: Text(action, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String day;
  final String time;
  final String title;
  final String room;

  const _ScheduleCard(this.day, this.time, this.title, this.room);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: AppTheme.glass(radius: 20),
      child: Row(
        children: [
          Container(width: 60, height: 60, decoration: AppTheme.goldGlow(radius: 18), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(time, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)), const SizedBox(height: 2), Text(day, style: const TextStyle(color: Colors.black54, fontSize: 8, fontWeight: FontWeight.w800))])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 5), Text(room.isEmpty ? 'استودیو اصلی' : room, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5))])),
          const Icon(Icons.chevron_left_rounded, color: Colors.white24),
        ],
      ),
    );
  }
}

class _CourseShowcase extends StatelessWidget {
  final CourseCatalogItem course;
  final VoidCallback onTap;

  const _CourseShowcase({required this.course, required this.onTap});

  String _money(int value) {
    final text = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '$text تومان';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: AppTheme.heroPanel(radius: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(course.imageAsset, fit: BoxFit.cover),
                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppTheme.background.withValues(alpha: .96)]))),
                  Positioned(right: 14, top: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .13), borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.gold.withValues(alpha: .3))), child: Text(course.category, style: const TextStyle(color: AppTheme.gold, fontSize: 8, fontWeight: FontWeight.w900)))),
                  Positioned(left: 14, right: 14, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(course.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10.5, height: 1.35)), const SizedBox(height: 9), Row(children: [Expanded(child: Text(_money(course.price), style: const TextStyle(color: AppTheme.gold2, fontWeight: FontWeight.w900, fontSize: 12))), const Icon(Icons.arrow_forward_rounded, color: AppTheme.gold, size: 18)])])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;
  final IconData icon;

  const _EmptyPanel({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glass(radius: 22),
      child: Column(children: [Icon(icon, color: AppTheme.gold, size: 34), const SizedBox(height: 10), Text(text, style: const TextStyle(color: AppTheme.muted, fontSize: 12))]),
    );
  }
}

