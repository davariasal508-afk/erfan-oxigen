import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/customer_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/customer_service.dart';
import '../../services/customer_session_service.dart';
import '../../services/session_service.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_dashboard.dart';
import '../admin/chat_screen.dart';
import '../common/beauty_hub_screen.dart';
import '../common/booking_screen.dart';
import '../student/student_dashboard.dart';
import '../teacher/teacher_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginStep { phone, password, otp }

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();

  late final AnimationController _logo = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  _LoginStep step = _LoginStep.phone;
  UserModel? user;
  CustomerModel? customer;
  bool obscure = true;
  bool loading = false;
  String error = '';
  String? localOtp;

  String _normalizePhone(String raw) {
    var value = raw.trim().replaceAll(' ', '').replaceAll('-', '');

    if (value.startsWith('0098')) {
      value = '+98${value.substring(4)}';
    }

    if (value.startsWith('98') && !value.startsWith('+')) {
      value = '+$value';
    }

    if (value.startsWith('0')) {
      value = '+98${value.substring(1)}';
    }

    return value;
  }

  Future<void> continueWithPhone() async {
    final phone = _normalizePhone(phoneController.text);

    if (phone.length < 10) {
      setState(() => error = 'شماره موبایل معتبر وارد کنید');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    await UserManager.initialize();
    await CustomerService.initialize();

    UserModel? foundUser;

    for (final item in UserManager.users) {
      if (_normalizePhone(item.phone) == phone && item.active) {
        foundUser = item;
        break;
      }
    }

    final foundCustomer =
        CustomerService.find(phone) ??
        CustomerService.find(phone.replaceFirst('+98', '0'));

    if (!mounted) return;

    if (foundUser == null && foundCustomer == null) {
      setState(() {
        loading = false;
        error = 'این شماره در ERFAN OXIGEN ثبت نشده است.';
      });
      return;
    }

    if (foundUser != null) {
      setState(() {
        user = foundUser;
        customer = null;
        step = _LoginStep.password;
        loading = false;
      });
      return;
    }

    final otp = await CustomerService.requestOtp(phone);

    if (!mounted) return;

    if (otp == null) {
      setState(() {
        loading = false;
        error = 'در حال حاضر امکان ارسال کد تأیید وجود ندارد.';
      });
      return;
    }

    setState(() {
      customer = foundCustomer;
      user = null;
      localOtp = otp;
      step = _LoginStep.otp;
      loading = false;
    });
  }

  Future<void> loginWithPassword() async {
    final currentUser = user;

    if (currentUser == null) return;

    if (passwordController.text.trim().isEmpty) {
      setState(() => error = 'رمز عبور را وارد کنید');
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    final loggedUser = await AuthService.login(
      _normalizePhone(currentUser.phone),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (loggedUser == null) {
      setState(() {
        loading = false;
        error = 'رمز عبور اشتباه است.';
      });
      return;
    }

    final Widget? page = switch (loggedUser.role) {
      'admin' => const AdminDashboard(),
      'teacher' => const TeacherDashboard(),
      'student' => const StudentDashboard(),
      _ => null,
    };

    if (page == null) {
      await SessionService.logout();

      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'نقش کاربر معتبر نیست.';
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> verifyCustomer() async {
    final currentCustomer = customer;

    if (currentCustomer == null) return;

    final enteredOtp = otpController.text.trim();

    final ok =
        CustomerService.verifyOtp(
          currentCustomer.phone,
          enteredOtp,
        ) ||
        CustomerService.verifyOtp(
          phoneController.text.trim(),
          enteredOtp,
        );

    if (!ok) {
      setState(() {
        error = 'کد تأیید اشتباه یا منقضی شده است.';
      });
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    await CustomerService.markPhoneVerified(currentCustomer);
    await CustomerSessionService.createSession(currentCustomer);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerHomeScreen(
          customerName: currentCustomer.name,
        ),
      ),
    );
  }

  void backToPhone() {
    setState(() {
      step = _LoginStep.phone;
      user = null;
      customer = null;
      localOtp = null;
      passwordController.clear();
      otpController.clear();
      error = '';
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _logo.dispose();
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/login_hero.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: .18),
                        Colors.black.withValues(alpha: .42),
                        AppTheme.background.withValues(alpha: .88),
                        AppTheme.background,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LoginGlowPainter(),
                  ),
                ),
              ),
              SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 18,
                      left: 20,
                      child: FadeTransition(
                        opacity: _intro,
                        child: const _LoginBrandText(),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      right: 20,
                      child: RotationTransition(
                        turns: Tween<double>(
                          begin: 0.0,
                          end: .04,
                        ).animate(_logo),
                        child: const OxygenLogoMark(
                          size: 74,
                          animated: true,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _intro,
                          curve: Curves.easeOut,
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .08),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _intro,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 16 : 24,
                              compact ? 84 : 96,
                              compact ? 16 : 24,
                              92,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: compact ? 480 : 540,
                              ),
                              child: _loginCard(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: _LoginTagline(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _loginCard() {
    final title = switch (step) {
      _LoginStep.phone => 'ورود به حساب',
      _LoginStep.password => 'حساب شناسایی شد',
      _LoginStep.otp => 'تأیید شماره مشتری',
    };

    final subtitle = switch (step) {
      _LoginStep.phone =>
        'شماره موبایل را وارد کنید؛ سیستم نقش شما را خودکار تشخیص می‌دهد.',
      _LoginStep.password =>
        'رمز عبور ${_roleTitle(user?.role)} را وارد کنید.',
      _LoginStep.otp =>
        'کد تأیید برای مشتری ثبت‌شده آماده است.',
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 28,
          sigmaY: 28,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            18,
          ),
          decoration: BoxDecoration(
            color: const Color(0xD70B0F15),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: .12),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x83000000),
                blurRadius: 38,
                offset: Offset(0, 24),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: AppTheme.goldGlow(
                      radius: 16,
                    ),
                    child: Icon(
                      step == _LoginStep.otp
                          ? Icons.sms_rounded
                          : Icons.lock_open_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                enabled: step == _LoginStep.phone,
                decoration: const InputDecoration(
                  labelText: 'شماره موبایل',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              if (step == _LoginStep.password) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  onSubmitted: (_) => loginWithPassword(),
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    prefixIcon:
                        const Icon(Icons.password_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      icon: Icon(
                        obscure
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                ),
              ],
              if (step == _LoginStep.otp) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'کد تأیید',
                    prefixIcon:
                        Icon(Icons.verified_user_rounded),
                  ),
                ),
                if (localOtp != null) ...[
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: AppTheme.outlineGold(
                      radius: 16,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Colors.white70,
                        ),
                        children: [
                          const TextSpan(
                            text: 'کد موقت نسخه نمایشی: ',
                          ),
                          TextSpan(
                            text: localOtp!,
                            style: const TextStyle(
                              color: AppTheme.gold2,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: error.isEmpty
                    ? const SizedBox(height: 6)
                    : Container(
                        key: ValueKey(error),
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(
                            alpha: .06,
                          ),
                          borderRadius:
                              BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.danger.withValues(
                              alpha: .18,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.danger,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: AppTheme.danger,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: loading
                      ? null
                      : switch (step) {
                          _LoginStep.phone =>
                            continueWithPhone,
                          _LoginStep.password =>
                            loginWithPassword,
                          _LoginStep.otp =>
                            verifyCustomer,
                        },
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                        ),
                  label: Text(
                    loading
                        ? 'در حال بررسی...'
                        : step == _LoginStep.phone
                            ? 'ادامه'
                            : step == _LoginStep.password
                                ? 'ورود به حساب'
                                : 'تأیید و ورود',
                  ),
                ),
              ),
              if (step != _LoginStep.phone) ...[
                const SizedBox(height: 7),
                TextButton.icon(
                  onPressed:
                      loading ? null : backToPhone,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.gold,
                  ),
                  label: const Text(
                    'تغییر شماره',
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'نقش کاربر فقط از روی شماره ثبت‌شده در سیستم تشخیص داده می‌شود.',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: .35,
                        ),
                        fontSize: 8.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleTitle(String? role) => switch (role) {
        'admin' => 'مدیر',
        'teacher' => 'مدرس',
        'student' => 'هنرجو',
        _ => 'کاربر',
      };
}

class _LoginBrandText extends StatelessWidget {
  const _LoginBrandText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ERFAN OXIGEN',
          style: brandWordmarkFont(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: Colors.white),
        ),
        const SizedBox(height: 3),
        const Text(
          'BARBER • ACADEMY • STUDIO',
          style: TextStyle(
            color: AppTheme.gold,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _LoginTagline extends StatelessWidget {
  const _LoginTagline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'یک تجربه متفاوت.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.gold2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'MORE THAN A HAIRCUT • IT’S A LIFESTYLE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .52),
            fontSize: 8.5,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LoginGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.gold.withValues(alpha: .10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            size.width * .76,
            size.height * .47,
          ),
          radius: size.width * .55,
        ),
      );

    canvas.drawCircle(
      Offset(
        size.width * .76,
        size.height * .47,
      ),
      size.width * .32,
      glow,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      false;
}

class CustomerHomeScreen extends StatefulWidget {
  final String customerName;

  const CustomerHomeScreen({
    super.key,
    required this.customerName,
  });

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {
  CustomerModel? get customer =>
      CustomerService.find(
        CustomerSessionService.customer?.phone ?? '',
      );

  Future<void> logout() async {
    await CustomerSessionService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  Future<void> claimBirthdayGift() async {
    final current = customer;

    if (current == null ||
        !current.birthdayGiftAvailable) {
      return;
    }

    await CustomerService.claimBirthdayGift(
      current,
    );

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'هدیه تولد ویژه شما فعال شد 🎁',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = customer;

    return OxygenPage(
      title: 'فضای مشتری',
      actions: [
        IconButton(
          onPressed: logout,
          tooltip: 'خروج',
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          34,
        ),
        children: [
          _CustomerHero(
            name: widget.customerName,
          ),
          const SizedBox(height: 14),
          if (BookingService.nextForCustomer(CustomerSessionService.customer?.phone ?? '') != null) ...[
            _NextAppointmentCard(booking: BookingService.nextForCustomer(CustomerSessionService.customer?.phone ?? '')!),
            const SizedBox(height: 14),
          ],
          if (current?.birthdayGiftAvailable == true) ...[
            _BirthdayCard(
              onClaim: claimBirthdayGift,
            ),
            const SizedBox(height: 14),
          ],
          const SectionTitle(
            title: 'دسترسی سریع',
            subtitle:
                'همه‌چیز در یک فضای خصوصی و ساده.',
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _CustomerAction(
                  icon:
                      Icons.event_available_rounded,
                  title: 'نوبت من',
                  subtitle:
                      'انتخاب زمان و سرویس',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BookingScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CustomerAction(
                  icon:
                      Icons.chat_bubble_rounded,
                  title: 'چت با آرایشگر',
                  subtitle: 'گفتگوی خصوصی',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ChatScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CustomerAction(
                  icon:
                      Icons.auto_awesome_rounded,
                  title: 'Beauty Studio',
                  subtitle: 'خدمات و دوره‌ها',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const BeautyHubScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CustomerAction(
                  icon:
                      Icons.notifications_rounded,
                  title: 'اعلان‌ها',
                  subtitle: 'خبرهای مهم شما',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/notifications',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(
            title: 'فضای اختصاصی شما',
            subtitle:
                'پیشنهادهای منتخب ERFAN OXIGEN.',
          ),
          const SizedBox(height: 12),
          const _OfferCard(
            title: 'Men’s Grooming Signature',
            subtitle:
                'یک تجربه کامل برای استایل، فید و ریش.',
            badge: 'EXCLUSIVE',
            icon: Icons.content_cut_rounded,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glass(
              radius: 22,
              strong: true,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: AppTheme.success,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ورود شما تا زمان خروج دستی حفظ می‌شود و شماره‌های ناشناس هیچ‌وقت وارد مرحله تأیید نمی‌شوند.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      height: 1.5,
                      fontSize: 10.5,
                    ),
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

class _CustomerHero extends StatefulWidget {
  final String name;

  const _CustomerHero({
    required this.name,
  });

  @override
  State<_CustomerHero> createState() =>
      _CustomerHeroState();
}

class _CustomerHeroState extends State<_CustomerHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat(reverse: true);

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
        final shift =
            (_controller.value - .5) * 10;

        return Container(
          height: 250,
          decoration:
              AppTheme.heroPanel(radius: 28),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(shift, 0),
                child: Image.asset(
                  'assets/images/login_hero.png',
                  fit: BoxFit.cover,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(
                        alpha: .04,
                      ),
                      Colors.black.withValues(
                        alpha: .44,
                      ),
                      AppTheme.background.withValues(
                        alpha: .98,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration:
                      AppTheme.outlineGold(
                    radius: 999,
                  ),
                  child: const Text(
                    'CLIENT LOUNGE',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 7.5,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سلام ${widget.name}',
                      style: const TextStyle(
                        color:
                            AppTheme.gold2,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'استایل شما،\nامضای شماست.',
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight:
                            FontWeight.w900,
                        height: .98,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'نوبت، چت با آرایشگر، پیشنهادها و Beauty Studio در یک تجربه یکپارچه.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final BookingModel booking;
  const _NextAppointmentCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = booking.date.difference(now);
    final isToday = booking.date.year == now.year && booking.date.month == now.month && booking.date.day == now.day;
    final hh = diff.inHours.clamp(0, 99).toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).clamp(0, 59).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppTheme.surface.withValues(alpha: .55),
        border: Border.all(color: AppTheme.gold.withValues(alpha: .2)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12))],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.gold.withValues(alpha: .10), Colors.transparent]))),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.surface2, border: Border.all(color: AppTheme.gold.withValues(alpha: .15))),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.gold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('نوبت بعدی شما', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                        const SizedBox(height: 2),
                        Text(
                          isToday ? 'امروز، ساعت ${booking.time}' : '${booking.date.year}/${booking.date.month.toString().padLeft(2, '0')}/${booking.date.day.toString().padLeft(2, '0')} — ساعت ${booking.time}',
                          style: TextStyle(color: AppTheme.gold.withValues(alpha: .8), fontSize: 11.5, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  if (diff.inMinutes > 0 && diff.inHours < 24)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.surface2, AppTheme.surface]),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: AppTheme.gold.withValues(alpha: .2)),
                      ),
                      child: Text('$hh:$mm', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, AppTheme.gold.withValues(alpha: .15), Colors.transparent]))),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.gold.withValues(alpha: .3), width: 1.4), color: Colors.black),
                    child: const Icon(Icons.person_rounded, color: AppTheme.gold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.service, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: AppTheme.gold.withValues(alpha: .9), size: 14),
                            const SizedBox(width: 3),
                            const Text('عرفان (مدیر)', style: TextStyle(color: AppTheme.gold, fontSize: 11.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.gold2, AppTheme.gold, AppTheme.bronze]),
                      boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: .3), blurRadius: 14, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CustomerAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.gold.withValues(alpha: .18)),
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.surface2, AppTheme.surface]),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  bottom: -16,
                  child: Opacity(
                    opacity: .10,
                    child: Image.asset('assets/images/oxigen_shield_mark.png', width: 90, filterQuality: FilterQuality.high),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.surface3, border: Border.all(color: AppTheme.gold.withValues(alpha: .25))),
                        child: Icon(icon, color: AppTheme.gold, size: 20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 10.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;

  const _OfferCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          AppTheme.heroPanel(
        radius: 24,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                AppTheme.goldGlow(
              radius: 16,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration:
                      BoxDecoration(
                    color: AppTheme.gold
                        .withValues(alpha: .1),
                    borderRadius:
                        BorderRadius
                            .circular(99),
                  ),
                  child: Text(
                    badge,
                    style:
                        const TextStyle(
                      color:
                          AppTheme.gold,
                      fontSize: 7.5,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left_rounded,
            color: AppTheme.gold,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _BirthdayCard extends StatelessWidget {
  final VoidCallback onClaim;

  const _BirthdayCard({
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3A2916),
            Color(0xFF16110A),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.gold.withValues(
            alpha: .28,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                AppTheme.goldGlow(
              radius: 16,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'تولدت مبارک 🎉',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'هدیه اختصاصی ERFAN OXIGEN برای امروز آماده است.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: onClaim,
            child: const Text('هدیه'),
          ),
        ],
      ),
    );
  }
}
