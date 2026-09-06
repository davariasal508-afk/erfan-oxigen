import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/current_user.dart';
import '../../services/customer_session_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_dashboard.dart';
import '../login/login_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  late final AnimationController _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late final AnimationController _percent = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
  late final Animation<double> _fade = CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween(begin: .78, end: 1.0).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _burst.forward();
    _intro.forward();
    _percent.forward();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    final valid = await SessionService.restoreSession();
    if (!mounted) return;
    final customerValid = await CustomerSessionService.restore();
    if (!mounted) return;
    if (customerValid && CustomerSessionService.customer != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerHomeScreen(customerName: CustomerSessionService.customer!.name)));
      return;
    }
    final user = CurrentUser.user;
    if (!valid || user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    final page = switch (user.role) {
      'admin' => const AdminDashboard(),
      'teacher' => const TeacherDashboard(),
      'student' => const StudentDashboard(),
      _ => const LoginScreen(),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _intro.dispose();
    _orbit.dispose();
    _burst.dispose();
    _percent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF10151D), AppTheme.background],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _burst,
            builder: (context, child) => CustomPaint(painter: _BurstPainter(_burst.value)),
          ),
          AnimatedBuilder(
            animation: _orbit,
            builder: (context, child) => CustomPaint(painter: _OrbitPainter(_orbit.value)),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OxygenAnimatedLogo(size: 152, showText: true),
                    const SizedBox(height: 22),
                    const Text('BARBER • ACADEMY • STUDIO', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                    const SizedBox(height: 26),
                    AnimatedBuilder(
                      animation: _percent,
                      builder: (context, child) {
                        final value = Curves.easeOutCubic.transform(_percent.value);
                        return SizedBox(
                          width: 82,
                          height: 82,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(size: const Size(82, 82), painter: _PercentRingPainter(value)),
                              Text('${(value * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppTheme.gold2)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('در حال آماده‌سازی استایل شما...', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double value;
  const _BurstPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0) return;
    final center = Offset(size.width / 2, size.height * .40);
    const rays = 28;
    final eased = Curves.easeOutQuart.transform(value);
    final opacity = (1 - value).clamp(0.0, 1.0);
    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * math.pi * 2;
      final len = size.width * .34 * eased;
      final start = Offset(center.dx + math.cos(angle) * 26, center.dy + math.sin(angle) * 26);
      final end = Offset(center.dx + math.cos(angle) * (26 + len), center.dy + math.sin(angle) * (26 + len));
      final paint = Paint()
        ..strokeWidth = 1.4
        ..color = AppTheme.gold.withValues(alpha: .5 * opacity);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.value != value;
}

class _PercentRingPainter extends CustomPainter {
  final double value;
  const _PercentRingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(4);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: .08),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5
        ..shader = const SweepGradient(colors: [AppTheme.gold2, AppTheme.gold, AppTheme.bronze]).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _PercentRingPainter oldDelegate) => oldDelegate.value != value;
}

class _OrbitPainter extends CustomPainter {
  final double value;

  _OrbitPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .44);
    final radius = size.width * .34;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = AppTheme.gold.withValues(alpha: .16);
    canvas.drawCircle(center, radius, paint);

    final dotAngle = value * math.pi * 2;
    final dot = Offset(center.dx + math.cos(dotAngle) * radius, center.dy + math.sin(dotAngle) * radius);
    final dotPaint = Paint()..color = AppTheme.gold2;
    canvas.drawCircle(dot, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => oldDelegate.value != value;
}
