import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  String query = '';

  List<UserModel> get admins {
    final q = query.trim().toLowerCase();
    return UserManager.getUsersByRole('admin').where((user) => q.isEmpty || user.name.toLowerCase().contains(q) || user.phone.contains(q)).toList();
  }

  Future<void> addAdmin() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen(initialRole: 'admin')));
    if (mounted) setState(() {});
  }

  Future<void> editAdmin(UserModel admin) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserScreen(user: admin)));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final list = admins;
    return OxygenPage(
      title: 'مدیران',
      floatingActionButton: FloatingActionButton.extended(onPressed: addAdmin, icon: const Icon(Icons.add), label: const Text('مدیر جدید')),
      child: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'جستجوی مدیر...', prefixIcon: Icon(Icons.search)))),
        Expanded(child: list.isEmpty ? const Center(child: Text('مدیری ثبت نشده است', style: TextStyle(color: AppTheme.muted))) : ListView.separated(padding: const EdgeInsets.all(18), itemCount: list.length, separatorBuilder: (context, index) => const SizedBox(height: 10), itemBuilder: (context, index) {
          final admin = list[index];
          final activePermissions = admin.permissions.values.where((value) => value).length;
          return Container(padding: const EdgeInsets.all(16), decoration: AppTheme.glass(radius: 20), child: Row(children: [Container(width: 52, height: 52, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.admin_panel_settings, color: Colors.black)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(admin.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(admin.phone, style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 4), Text('$activePermissions دسترسی فعال', style: const TextStyle(color: AppTheme.gold, fontSize: 12))])), PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') editAdmin(admin); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش دسترسی‌ها'))])],));
        }))
      ]),
    );
  }
}
