import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';
import 'chat_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String query = '';

  List<UserModel> get students {
    final q = query.trim().toLowerCase();
    return UserManager.getUsersByRole('student').where((user) {
      return q.isEmpty || user.name.toLowerCase().contains(q) || user.phone.contains(q) || (user.course ?? '').toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addStudent() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen(initialRole: 'student')));
    if (mounted) setState(() {});
  }

  Future<void> editStudent(UserModel student) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserScreen(user: student)));
    if (mounted) setState(() {});
  }

  Future<void> deleteStudent(UserModel student) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف هنرجو'),
        content: Text('آیا «${student.name}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (yes != true) return;
    await UserManager.removeUser(student);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${student.name} حذف شد')));
  }

  @override
  Widget build(BuildContext context) {
    final list = students;
    return OxygenPage(
      title: 'هنرجوها',
      floatingActionButton: FloatingActionButton.extended(onPressed: addStudent, icon: const Icon(Icons.add), label: const Text('هنرجوی جدید')),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), child: TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(hintText: 'جستجوی هنرجو...', prefixIcon: Icon(Icons.search)))),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('هنرجویی با این مشخصات پیدا نشد', style: TextStyle(color: AppTheme.muted)))
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final student = list[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glass(radius: 20),
                        child: Row(children: [
                          Container(width: 52, height: 52, decoration: AppTheme.goldGlow(radius: 16), child: const Icon(Icons.person, color: Colors.black)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(student.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 4), Text(student.course ?? 'بدون دوره', style: const TextStyle(color: AppTheme.muted)), const SizedBox(height: 3), Text('${student.phone} • کد ملی: ${student.nationalId ?? '-'}', style: const TextStyle(color: Colors.white54, fontSize: 11)), if ((student.fatherPhone ?? '').isNotEmpty) Text('ولی: ${student.fatherPhone}', style: const TextStyle(color: Colors.white38, fontSize: 10))])),
                          Column(children: [
                            Icon(student.active ? Icons.check_circle : Icons.pause_circle, color: student.active ? Colors.greenAccent : Colors.orangeAccent, size: 20),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(tooltip: 'پیام', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(contact: student))), icon: const Icon(Icons.forum_outlined, color: AppTheme.gold, size: 20)),
                              PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') editStudent(student); if (value == 'delete') deleteStudent(student); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))])
                            ])]),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
