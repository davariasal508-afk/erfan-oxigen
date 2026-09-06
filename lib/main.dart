import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'screens/common/notifications_screen.dart';
import 'screens/common/design_reference_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/exam_service.dart';
import 'services/admin_profile_service.dart';
import 'services/booking_service.dart';
import 'services/chat_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/schedule_service.dart';
import 'services/customer_service.dart';
import 'services/course_catalog_service.dart';
import 'services/course_enrollment_service.dart';
import 'services/formula_service.dart';
import 'services/portfolio_service.dart';
import 'services/view_tracking_service.dart';
import 'services/backend_api.dart';
import 'services/user_manager.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserManager.loadUsers();
  await ExamService.initialize();
  await AdminProfileService.initialize();
  await BookingService.initialize();
  await ChatService.initialize();
  await AdService.initialize();
  await BackendApi.initialize();
  await NotificationService.initialize();
  await ScheduleService.initialize();
  await CustomerService.initialize();
  await CourseCatalogService.initialize();
  await CourseEnrollmentService.initialize();
  await FormulaService.initialize();
  await PortfolioService.initialize();
  await ViewTrackingService.initialize();
  runApp(const OxygenApp());
}

class OxygenApp extends StatelessWidget {
  const OxygenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ERFAN OXIGEN',
      onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => const SplashScreen()),
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      onGenerateRoute: (settings) {
        final widget = switch (settings.name) {
          '/splash' => const SplashScreen(),
          '/design-reference' => const DesignReferenceScreen(),
          '/login' => const LoginScreen(),
          '/notifications' => const NotificationsScreen(),
          _ => const SplashScreen(),
        };
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: SlideTransition(position: Tween(begin: const Offset(0, .018), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)), child: child)),
        );
      },
      locale: const Locale('fa'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: '/splash',
    );
  }
}
