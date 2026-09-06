import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel user;
  const EditUserScreen({super.key, required this.user});
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late final TextEditingController name = TextEditingController(text: widget.user.name);
  late final TextEditingController password = TextEditingController(text: widget.user.password);
  late final TextEditingController fatherPhone = TextEditingController(text: widget.user.fatherPhone ?? '');
  late final TextEditingController nationalId = TextEditingController(text: widget.user.nationalId ?? '');
  late final TextEditingController extra = TextEditingController(text: widget.user.role == 'teacher' ? widget.user.specialty : widget.user.course);
  late bool active = widget.user.active;
  late Map<String, bool> permissions = Map<String, bool>.from(widget.user.permissions);

  Future<void> save() async {
    final updated = UserModel(
      name: name.text.trim(),
      phone: widget.user.phone,
      password: password.text.trim(),
      role: widget.user.role,
      active: active,
      permissions: permissions,
      specialty: widget.user.role == 'teacher' ? extra.text.trim() : widget.user.specialty,
      course: widget.user.role == 'student' ? extra.text.trim() : widget.user.course,
      fatherPhone: widget.user.fatherPhone,
      nationalId: widget.user.nationalId,
      photoPath: widget.user.photoPath,
    );
    await UserManager.updateUser(widget.user, updated);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    name.dispose(); password.dispose(); fatherPhone.dispose(); nationalId.dispose(); extra.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.user.role == 'student';
    return OxygenPage(
      title: 'ویرایش ${widget.user.name}',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SectionTitle(title: 'هویت ثبت‌شده', subtitle: 'نام، شماره، کد ملی و اطلاعات ولی از این صفحه قابل تغییر نیستند.'),
          const SizedBox(height: 12),
          _locked('نام', widget.user.name),
          _locked('شماره موبایل', widget.user.phone),
          if (student) _locked('شماره پدر/ولی', widget.user.fatherPhone ?? '-'),
          if (student) _locked('کد ملی', widget.user.nationalId ?? '-'),
          if (student) _lockedPhoto(),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور جدید')),
          if (widget.user.role == 'teacher') ...[const SizedBox(height: 10), TextField(controller: extra, decoration: const InputDecoration(labelText: 'تخصص مدرس'))],
          if (student) ...[const SizedBox(height: 10), TextField(controller: extra, decoration: const InputDecoration(labelText: 'دوره هنرجو'))],
          const SizedBox(height: 14),
          const SectionTitle(title: 'دسترسی', subtitle: 'این بخش توسط مدیر قابل تغییر است.'),
          ...permissions.keys.map((key) => SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(_permissionTitle(key)), value: permissions[key] ?? false, onChanged: (v) => setState(() => permissions[key] = v))),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('کاربر فعال'), value: active, onChanged: (v) => setState(() => active = v)),
          const SizedBox(height: 18),
          SizedBox(height: 56, child: ElevatedButton.icon(onPressed: save, icon: const Icon(Icons.save_rounded), label: const Text('ذخیره تغییرات'))),
        ],
      ),
    );
  }

  Widget _lockedPhoto() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glass(radius: 16),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white10),
            child: widget.user.photoPath == null
                ? const Icon(Icons.person_rounded, color: AppTheme.gold)
                : Image.file(File(widget.user.photoPath!), fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('عکس هنرجو — قفل شده', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const Icon(Icons.lock_outline_rounded, color: AppTheme.gold, size: 18),
        ],
      ),
    );
  }

  Widget _locked(String title, String value) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: AppTheme.glass(radius: 16),
        child: Row(children: [const Icon(Icons.lock_outline_rounded, color: AppTheme.gold, size: 18), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 11)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w800))]))]),
      );

  String _permissionTitle(String key) => switch (key) {
        'manageUsers' => 'مدیریت کاربران',
        'viewStudents' => 'مشاهده هنرجوها',
        'sendMessage' => 'ارسال پیام',
        'viewReports' => 'مشاهده گزارش‌ها',
        'editContent' => 'ویرایش محتوا',
        _ => key,
      };
}
