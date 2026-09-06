import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'chat_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  String query = '';

  List<UserModel> get teachers {
    final q = query.trim().toLowerCase();
    return UserManager.getUsersByRole('teacher').where((user) {
      return q.isEmpty || user.name.toLowerCase().contains(q) || user.phone.contains(q) || (user.specialty ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addTeacher() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen(initialRole: 'teacher')));
    if (mounted) setState(() {});
  }

  Future<void> editTeacher(UserModel teacher) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserScreen(user: teacher)));
    if (mounted) setState(() {});
  }

  Future<void> deleteTeacher(UserModel teacher) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مدرس'),
        content: Text('آیا «${teacher.name}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (yes != true) return;
    await UserManager.removeUser(teacher);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${teacher.name} حذف شد')));
  }

  @override
  Widget build(BuildContext context) {
    final list = teachers;
    return OxygenPage(
      title: 'مدرس‌ها',
      floatingActionButton: FloatingActionButton.extended(onPressed: addTeacher, icon: const Icon(Icons.add), label: const Text('مدرس جدید')),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'جستجوی مدرس...', prefixIcon: Icon(Icons.search))),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('مدرسی با این مشخصات پیدا نشد', style: TextStyle(color: AppTheme.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final teacher = list[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glass(radius: 20),
                        child: Row(
                          children: [
                            Container(width: 52, height: 52, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.school, color: Colors.black)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(teacher.specialty ?? 'بدون تخصص', style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 3), Text(teacher.phone, style: const TextStyle(color: Colors.white54, fontSize: 12))])),
                            Column(
                              children: [
                                Icon(teacher.active ? Icons.check_circle : Icons.pause_circle, color: teacher.active ? Colors.greenAccent : Colors.orangeAccent, size: 20),
                                IconButton(tooltip: 'پیام', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(contact: teacher))), icon: const Icon(Icons.forum_outlined, color: AppTheme.gold, size: 20)),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') editTeacher(teacher);
                                    if (value == 'delete') deleteTeacher(teacher);
                                  },
                                  itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
