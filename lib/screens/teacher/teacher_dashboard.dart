import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/current_user.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import '../admin/chat_screen.dart';
import '../admin/students_screen.dart';
import '../common/beauty_hub_screen.dart';
import '../common/color_lab_screen.dart';
import 'portfolio_review_screen.dart';
import '../common/courses_screen.dart';
import '../common/certificate_screen.dart';
import '../common/exam_overview_screen.dart';
import '../common/profile_screen.dart';
import '../common/notifications_screen.dart';
import '../common/schedule_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final students = UserManager.getUsersByRole('student').length;
    return Scaffold(
      drawer: const OxygenSidePanel(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 118,
            backgroundColor: AppTheme.background,
            leading: Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu_rounded))),
            title: const OxygenBrand(compact: true, iconSize: 36),
            actions: [
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Icon(Icons.person_outline_rounded)),
              IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout_rounded)),
            ],
            flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF271A0E), AppTheme.background], begin: Alignment.topRight, end: Alignment.bottomLeft)))),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PremiumHero(
                  eyebrow: 'TEACHER STUDIO',
                  title: 'کلاس را به تجربه تبدیل کن.',
                  subtitle: CurrentUser.specialty.isEmpty ? 'داشبورد حرفه‌ای مدرس برای کلاس، هنرجو و ارزیابی.' : CurrentUser.specialty,
                  actionLabel: 'Men’s Grooming Studio',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeautyHubScreen())),
                  icon: Icons.school_rounded,
                  accentColor: AppTheme.success,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.glass(radius: 22, strong: true),
                  child: Row(
                    children: [
                      Container(width: 50, height: 50, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.school_rounded, color: Colors.black)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('سلام ${CurrentUser.name}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 4), const Text('امروز وقت ساختن یک کلاس به‌یادماندنی است.', style: TextStyle(color: AppTheme.muted, fontSize: 12))])),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: StatTile(label: 'هنرجوها', value: '$students', icon: Icons.groups_rounded, trend: '+۵')), const SizedBox(width: 10), const Expanded(child: StatTile(label: 'جلسه امروز', value: '۲', icon: Icons.today_rounded))]),
                const SizedBox(height: 10),
                const Row(children: [Expanded(child: StatTile(label: 'میانگین رضایت', value: '۹۶٪', icon: Icons.favorite_rounded, trend: '+۴٪')), SizedBox(width: 10), Expanded(child: StatTile(label: 'نمره کلاس', value: 'A+', icon: Icons.workspace_premium_rounded))]),
                const SizedBox(height: 24),
                const SectionTitle(title: 'برنامه امروز', subtitle: 'سه حرکت اصلی برای یک روز حرفه‌ای'),
                const SizedBox(height: 12),
                const _TeacherAgenda(time: '17:00', title: 'Masterclass • Color Lab', detail: '۱۲ هنرجو • رنگ و مش پیشرفته', icon: Icons.palette_rounded),
                const SizedBox(height: 8),
                const _TeacherAgenda(time: '18:30', title: 'Hands-on • Barber', detail: 'تمرین فید و فرم‌دهی', icon: Icons.content_cut_rounded),
                const SizedBox(height: 8),
                const _TeacherAgenda(time: '20:00', title: 'Review', detail: 'بازخورد نمونه‌کارها', icon: Icons.rate_review_rounded),
                const SizedBox(height: 22),
                const SectionTitle(title: 'ابزارهای مدرس'),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth > 620 ? 3 : 2;
                  final items = <Widget>[
                    ActionCard(title: 'کلاس‌های من', subtitle: 'برنامه هفتگی و جلسات', icon: Icons.calendar_month_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen(title: 'کلاس‌های من')))),
                    ActionCard(title: 'هنرجوها', subtitle: 'فهرست و پیشرفت', icon: Icons.groups_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentsScreen()))),
                    ActionCard(title: 'آزمون‌ها', subtitle: 'ارزیابی و نتایج', icon: Icons.assignment_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamOverviewScreen(title: 'آزمون‌های من', teacherView: true)))),
                    ActionCard(title: 'چت با مدیر', subtitle: 'گفتگوی خصوصی با عرفان', icon: Icons.support_agent_rounded, badge: 'PRIVATE', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    ActionCard(title: 'گروه گفتگو', subtitle: 'ارتباط با هنرجوها', icon: Icons.groups_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    ActionCard(title: 'Color Lab', subtitle: 'چرخ رنگ و فرمول واقعی', icon: Icons.palette_outlined, badge: 'PRO', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColorLabScreen()))),
                    ActionCard(title: 'بررسی نمونه‌کارها', subtitle: 'نمره‌دهی و بازخورد Before/After', icon: Icons.rate_review_rounded, badge: 'REVIEW', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioReviewScreen()))),
                    ActionCard(title: 'دوره‌ها', subtitle: 'مسیر آموزشی و جلسات', icon: Icons.play_lesson_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen()))),
                    ActionCard(title: 'گواهی‌ها', subtitle: 'مدارک و Certificates', icon: Icons.workspace_premium_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificateScreen()))),
                    ActionCard(title: 'اعلان‌ها', subtitle: 'پیام‌ها و تغییرات برنامه', icon: Icons.notifications_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    ActionCard(title: 'پروفایل', subtitle: 'اطلاعات حساب', icon: Icons.person_outline_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                  ];
                  return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: columns == 3 ? 156 : 150), itemBuilder: (_, index) => items[index]);
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherAgenda extends StatelessWidget {
  final String time;
  final String title;
  final String detail;
  final IconData icon;

  const _TeacherAgenda({required this.time, required this.title, required this.detail, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 18),
      child: Row(children: [Container(width: 52, height: 52, decoration: AppTheme.goldGlow(radius: 15), child: Icon(icon, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(detail, style: const TextStyle(color: AppTheme.muted, fontSize: 11))])), Text(time, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 12))]),
    );
  }
}
