import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/user_manager.dart';
import '../../theme/app_theme.dart';

class AddUserScreen extends StatefulWidget {
  final String initialRole;
  const AddUserScreen({super.key, this.initialRole = 'teacher'});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final fatherPhone = TextEditingController();
  final nationalId = TextEditingController();
  String? photoPath;
  final password = TextEditingController();
  final extra = TextEditingController();
  late String role = widget.initialRole;
  bool active = true;
  final permissions = <String, bool>{
    'manageUsers': false,
    'viewStudents': false,
    'sendMessage': false,
    'viewReports': false,
    'editContent': false,
  };

  @override
  void initState() {
    super.initState();
    _setRoleDefaults();
  }

  void _setRoleDefaults() {
    if (role == 'admin') {
      permissions.updateAll((key, value) => true);
    } else if (role == 'teacher') {
      permissions.updateAll((key, value) => false);
      permissions['viewStudents'] = true;
      permissions['sendMessage'] = true;
      permissions['editContent'] = true;
    } else {
      permissions.updateAll((key, value) => false);
      permissions['sendMessage'] = true;
    }
  }

  Future<void> save() async {
    final n = name.text.trim();
    final p = phone.text.trim();
    final pwd = password.text.trim();
    if (n.isEmpty || p.isEmpty || pwd.isEmpty) {
      _error('نام، شماره موبایل و رمز عبور الزامی است.');
      return;
    }
    if (UserManager.users.any((u) => u.phone == p)) {
      _error('این شماره قبلاً در سیستم ثبت شده است.');
      return;
    }
    if (role == 'student' && (fatherPhone.text.trim().isEmpty || nationalId.text.trim().isEmpty)) {
      _error('برای هنرجو شماره پدر و کد ملی الزامی است.');
      return;
    }
    if (role == 'teacher' && extra.text.trim().isEmpty) {
      _error('تخصص مدرس را وارد کنید.');
      return;
    }
    if (role == 'student' && extra.text.trim().isEmpty) {
      _error('دوره هنرجو را وارد کنید.');
      return;
    }
    final user = UserModel(
      name: n,
      phone: p,
      password: pwd,
      role: role,
      active: active,
      permissions: Map<String, bool>.from(permissions),
      specialty: role == 'teacher' ? extra.text.trim() : null,
      course: role == 'student' ? extra.text.trim() : null,
      fatherPhone: role == 'student' ? fatherPhone.text.trim() : null,
      nationalId: role == 'student' ? nationalId.text.trim() : null,
      photoPath: role == 'student' ? photoPath : null,
    );
    await UserManager.addUser(user);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _error(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    fatherPhone.dispose();
    nationalId.dispose();
    password.dispose();
    extra.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = role == 'student';
    return OxygenPage(
      title: 'ثبت کاربر جدید',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SectionTitle(title: 'اطلاعات پایه', subtitle: 'اطلاعات هویتی هنرجو پس از ثبت، قابل ویرایش نیستند.'),
          const SizedBox(height: 12),
          _field(name, 'نام و نام خانوادگی'),
          _field(phone, 'شماره موبایل', keyboardType: TextInputType.phone),
          if (student) _field(fatherPhone, 'شماره پدر/ولی', keyboardType: TextInputType.phone),
          if (student) _field(nationalId, 'کد ملی', keyboardType: TextInputType.number),
          if (student) _studentPhotoPicker(),
          _field(password, 'رمز عبور', obscure: true),
          DropdownButtonFormField<String>(
            initialValue: role,
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('مدیر')),
              DropdownMenuItem(value: 'teacher', child: Text('مدرس')),
              DropdownMenuItem(value: 'student', child: Text('هنرجو')),
            ],
            onChanged: (v) => setState(() { role = v ?? role; _setRoleDefaults(); }),
            decoration: const InputDecoration(labelText: 'نوع کاربر'),
          ),
          const SizedBox(height: 12),
          if (role == 'teacher') _field(extra, 'تخصص مدرس'),
          if (role == 'student') _field(extra, 'دوره هنرجو'),
          const SizedBox(height: 8),
          const SectionTitle(title: 'دسترسی', subtitle: 'قابل تنظیم از همین‌جا'),
          ...permissions.keys.map((key) => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_permissionTitle(key)),
                value: permissions[key] ?? false,
                onChanged: (v) => setState(() => permissions[key] = v),
              )),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('کاربر فعال'), value: active, onChanged: (v) => setState(() => active = v)),
          const SizedBox(height: 18),
          SizedBox(height: 56, child: ElevatedButton.icon(onPressed: save, icon: const Icon(Icons.person_add_rounded), label: const Text('ثبت کاربر'))),
        ],
      ),
    );
  }

  Widget _studentPhotoPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
          if (!mounted || image == null) return;
          setState(() => photoPath = image.path);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glass(radius: 18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white10,
                ),
                child: photoPath == null
                    ? const Icon(Icons.add_a_photo_rounded, color: AppTheme.gold)
                    : Image.file(File(photoPath!), fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('عکس هنرجو', style: TextStyle(fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('پس از ثبت، عکس در ویرایش معمولی قابل تغییر نیست.', style: TextStyle(color: AppTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppTheme.gold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboardType, bool obscure = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: c, keyboardType: keyboardType, obscureText: obscure, decoration: InputDecoration(labelText: label)),
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
