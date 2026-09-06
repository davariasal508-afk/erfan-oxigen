import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/current_user.dart';
import '../../theme/app_theme.dart';
import '../admin/chat_screen.dart';
import '../common/beauty_hub_screen.dart';
import '../common/portfolio_screen.dart';
import '../common/courses_screen.dart';
import '../common/certificate_screen.dart';
import '../common/exam_overview_screen.dart';
import '../common/notifications_screen.dart';
import '../common/profile_screen.dart';
import '../common/schedule_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  Future<void> logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
              IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded)),
              IconButton(onPressed: () => logout(context), icon: const Icon(Icons.logout_rounded)),
            ],
            flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF271A0E), AppTheme.background], begin: Alignment.topRight, end: Alignment.bottomLeft)))),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PremiumHero(
                  eyebrow: 'STUDENT EXPERIENCE',
                  title: 'از هنرجو تا استایلیست.',
                  subtitle: CurrentUser.course.isEmpty ? 'مسیر رشد، کلاس و نمونه‌کار خودت را در یک جا ببین.' : CurrentUser.course,
                  actionLabel: 'Men’s Grooming Studio',
                  onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeautyHubScreen())),
                  icon: Icons.auto_stories_rounded,
                  accentColor: AppTheme.gold2,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.glass(radius: 22, strong: true),
                  child: Row(children: [Container(width: 50, height: 50, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.person_rounded, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('سلام ${CurrentUser.name}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 4), const Text('امروز یک قدم دیگر به سطح حرفه‌ای نزدیک شو.', style: TextStyle(color: AppTheme.muted, fontSize: 12))]))]),
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 12),
                Row(children: [const Expanded(child: StatTile(label: 'کلاس این هفته', value: '۴', icon: Icons.school_rounded)), const SizedBox(width: 10), const Expanded(child: StatTile(label: 'نرخ پیشرفت', value: '۷۸٪', icon: Icons.trending_up_rounded, trend: '+۱۲٪'))]),
                const SizedBox(height: 10),
                const Row(children: [Expanded(child: StatTile(label: 'میانگین نمره', value: '۱۸.۷', icon: Icons.grade_rounded)), SizedBox(width: 10), Expanded(child: StatTile(label: 'اعلان جدید', value: '۳', icon: Icons.notifications_rounded))]),
                const SizedBox(height: 22),
                const SectionTitle(title: 'مسیر امروز', subtitle: 'برنامه پیشنهادی برای رشد سریع‌تر'),
                const SizedBox(height: 12),
                const _StudentStep(step: '01', title: 'کلاس Color Lab', detail: '۱۷:۰۰ • رنگ و مش پیشرفته', icon: Icons.palette_rounded),
                const SizedBox(height: 8),
                const _StudentStep(step: '02', title: 'تمرین عملی', detail: '۱۸:۳۰ • فید و فرم‌دهی', icon: Icons.content_cut_rounded),
                const SizedBox(height: 8),
                const _StudentStep(step: '03', title: 'Review & Score', detail: '۲۰:۰۰ • بازخورد نمونه‌کار', icon: Icons.star_rounded),
                const SizedBox(height: 22),
                const SectionTitle(title: 'دسترسی سریع'),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth > 620 ? 3 : 2;
                  final items = <Widget>[
                    ActionCard(title: 'کلاس‌های من', subtitle: 'برنامه هفتگی و جلسات', icon: Icons.school_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen(title: 'کلاس‌های من')))),
                    ActionCard(title: 'برنامه کلاس‌ها', subtitle: 'زمان‌بندی آموزشگاه', icon: Icons.calendar_month_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()))),
                    ActionCard(title: 'آزمون‌ها', subtitle: 'آزمون و نمرات', icon: Icons.assignment_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamOverviewScreen(title: 'آزمون‌های من', studentView: true)))),
                    ActionCard(title: 'نمرات', subtitle: 'کارنامه و نتایج', icon: Icons.grade_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamOverviewScreen(title: 'نمرات', studentView: true)))),
                    ActionCard(title: 'Men’s Grooming Studio', subtitle: 'Fade Lab و Lookbook', icon: Icons.auto_awesome_rounded, badge: 'NEW', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeautyHubScreen()))),
                    ActionCard(title: 'چت با مدیر', subtitle: 'گفتگوی خصوصی با عرفان', icon: Icons.support_agent_rounded, badge: 'PRIVATE', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    ActionCard(title: 'چت با مدرس', subtitle: 'ارتباط خصوصی با مدرس', icon: Icons.school_rounded, badge: 'PRIVATE', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    ActionCard(title: 'گروه گفتگو', subtitle: 'ارتباط با آموزشگاه', icon: Icons.forum_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()))),
                    ActionCard(title: 'اعلان‌ها', subtitle: 'پیام و اطلاعیه', icon: Icons.notifications_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    ActionCard(title: 'پروفایل من', subtitle: 'اطلاعات حساب', icon: Icons.person_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
                    ActionCard(title: 'نمونه‌کارها', subtitle: 'Portfolio و Before/After', icon: Icons.photo_library_rounded, badge: 'SHOWCASE', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioScreen()))),
                    ActionCard(title: 'دوره‌ها', subtitle: 'مسیر آموزشی و جلسات', icon: Icons.play_lesson_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen()))),
                    ActionCard(title: 'گواهی‌ها', subtitle: 'مدارک و Certificates', icon: Icons.workspace_premium_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificateScreen()))),
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

class _StudentStep extends StatelessWidget {
  final String step;
  final String title;
  final String detail;
  final IconData icon;

  const _StudentStep({required this.step, required this.title, required this.detail, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glass(radius: 18),
      child: Row(children: [Container(width: 52, height: 52, decoration: AppTheme.goldGlow(radius: 15), child: Icon(icon, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(detail, style: const TextStyle(color: AppTheme.muted, fontSize: 11))])), Text(step, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 14))]),
    );
  }
}
