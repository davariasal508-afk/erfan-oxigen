import 'package:flutter/material.dart';
import '../../services/admin_profile_service.dart';
import '../../services/backend_api.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController adminName = TextEditingController(text: AdminProfileService.displayName);
  late final TextEditingController baseUrl = TextEditingController(text: BackendApi.baseUrl);
  bool backendEnabled = BackendApi.enabled;

  @override
  void dispose() { adminName.dispose(); baseUrl.dispose(); super.dispose(); }

  Future<void> save() async {
    await AdminProfileService.setDisplayName(adminName.text.trim().isEmpty ? 'عرفان' : adminName.text.trim());
    await BackendApi.setConfig(isEnabled: backendEnabled, url: baseUrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تنظیمات ذخیره شد')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return OxygenPage(title: 'مرکز کنترل', child: ListView(padding: const EdgeInsets.fromLTRB(18, 14, 18, 32), children: [
      const SectionTitle(title: 'هویت مدیر', subtitle: 'نام این حساب در چت و اعلان‌ها نمایش داده می‌شود و قابل تغییر است.'),
      const SizedBox(height: 12),
      TextField(controller: adminName, decoration: const InputDecoration(labelText: 'نام نمایشی مدیر', prefixIcon: Icon(Icons.badge_rounded))),
      const SizedBox(height: 20),
      const SectionTitle(title: 'سرور', subtitle: 'اتصال به Backend محلی / شبکه خصوصی'),
      const SizedBox(height: 12),
      SwitchListTile(contentPadding: EdgeInsets.zero, value: backendEnabled, onChanged: (v) => setState(() => backendEnabled = v), title: const Text('فعال‌سازی Backend'), subtitle: const Text('در حالت خاموش، داده‌های محلی همچنان کار می‌کنند.', style: TextStyle(color: AppTheme.muted)), secondary: const Icon(Icons.dns_rounded, color: AppTheme.gold)),
      const SizedBox(height: 8),
      TextField(controller: baseUrl, decoration: const InputDecoration(labelText: 'آدرس سرور', prefixIcon: Icon(Icons.link_rounded))),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: () async { final ok = await BackendApi.health(); if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'سرور آنلاین است ✅' : 'سرور در دسترس نیست'))); }, icon: const Icon(Icons.health_and_safety_rounded), label: const Text('تست اتصال سرور')),
      const SizedBox(height: 20),
      const SectionTitle(title: 'امنیت و کاربران', subtitle: 'وضعیت فعلی سیستم'),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: AppTheme.glass(radius: 20), child: Column(children: [Row(children: [const Icon(Icons.groups_rounded, color: AppTheme.gold), const SizedBox(width: 10), const Text('کاربران فعال', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text('${UserManager.users.where((u) => u.active).length}')]), const SizedBox(height: 12), Row(children: [const Icon(Icons.school_rounded, color: AppTheme.gold), const SizedBox(width: 10), const Text('هنرجوها', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), Text('${UserManager.getUsersByRole('student').length}')]), const SizedBox(height: 12), Row(children: [const Icon(Icons.person_search_rounded, color: AppTheme.gold), const SizedBox(width: 10), const Text('مشتری‌ها', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), const Text('از بخش مشتری‌ها مدیریت می‌شود')])])),
      const SizedBox(height: 18),
      SizedBox(height: 54, child: ElevatedButton.icon(onPressed: save, icon: const Icon(Icons.save_rounded), label: const Text('ذخیره تنظیمات'))),
    ]));
  }
}
