import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/portfolio_model.dart';
import '../../services/course_catalog_service.dart';
import '../../services/course_enrollment_service.dart';
import '../../services/current_user.dart';
import '../../services/portfolio_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/course_image.dart';

/// «نمونه‌کارهای من» — آکادمی، دوره‌های من، ارسال نمونه‌کار و تاریخچه با نمره نهایی.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String? _imagePath;
  String? _courseId;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = CurrentUser.phone;
    final items = PortfolioService.forStudent(phone);
    final approved = items.where((e) => e.status == PortfolioStatus.approved).toList();
    final avg = approved.isEmpty ? null : approved.map((e) => e.finalScore ?? 0).reduce((a, b) => a + b) / approved.length;
    final myCourses = CourseCatalogService.items.where((c) => CourseEnrollmentService.isEnrolled(c.id, phone)).toList();

    return OxygenPage(
      title: 'نمونه‌کارهای من',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        children: [
          _AcademySummaryCard(average: avg),
          const SizedBox(height: 22),
          Row(children: const [Icon(Icons.menu_book_rounded, color: AppTheme.gold, size: 20), SizedBox(width: 8), Text('دوره‌های من', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          if (myCourses.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              decoration: AppTheme.glass(radius: 18),
              child: const Text('هنوز در دوره‌ای ثبت‌نام نکرده‌اید.', style: TextStyle(color: AppTheme.muted)),
            )
          else
            ...myCourses.map((c) => _MyCourseRow(course: c)),
          const SizedBox(height: 22),
          Row(children: const [Icon(Icons.upload_file_rounded, color: AppTheme.gold, size: 20), SizedBox(width: 8), Text('ارسال نمونه کار', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppTheme.surface.withValues(alpha: .8),
              border: Border.all(color: AppTheme.gold.withValues(alpha: .2)),
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withValues(alpha: .3),
                      border: Border.all(color: AppTheme.gold.withValues(alpha: .3)),
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.surface2, border: Border.all(color: AppTheme.gold.withValues(alpha: .3))),
                                child: const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.gold, size: 28),
                              ),
                              const SizedBox(height: 10),
                              const Text('آپلود تصویر نمونه کار', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                              const SizedBox(height: 3),
                              const Text('فرمت‌های مجاز: JPG, PNG', style: TextStyle(color: AppTheme.muted, fontSize: 10)),
                            ],
                          )
                        : Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerRight, child: Text('انتخاب دوره مربوطه', style: TextStyle(color: AppTheme.muted, fontSize: 10.5, fontWeight: FontWeight.w700))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.black.withValues(alpha: .25), border: Border.all(color: AppTheme.gold.withValues(alpha: .2))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _courseId,
                      hint: const Text('انتخاب کنید', style: TextStyle(color: AppTheme.muted)),
                      dropdownColor: AppTheme.surface2,
                      items: myCourses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                      onChanged: (v) => setState(() => _courseId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Align(alignment: Alignment.centerRight, child: Text('عنوان نمونه کار', style: TextStyle(color: AppTheme.muted, fontSize: 10.5, fontWeight: FontWeight.w700))),
                const SizedBox(height: 6),
                TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'مثال: اجرای سایه محو (Skin Fade)'), onChanged: (_) => setState(() {})),
                const SizedBox(height: 14),
                const Align(alignment: Alignment.centerRight, child: Text('توضیحات (اختیاری)', style: TextStyle(color: AppTheme.muted, fontSize: 10.5, fontWeight: FontWeight.w700))),
                const SizedBox(height: 6),
                TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'توضیحاتی درباره تکنیک‌های استفاده‌شده...')),
                const SizedBox(height: 18),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: (_imagePath != null && _titleCtrl.text.trim().isNotEmpty) ? _submit : null,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('ارسال برای بررسی'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(children: const [Icon(Icons.history_edu_rounded, color: AppTheme.gold, size: 20), SizedBox(width: 8), Text('تاریخچه نمونه کارها', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('هنوز نمونه‌کاری ثبت نکرده‌اید.', style: TextStyle(color: AppTheme.muted))))
          else
            ...items.map((e) => Padding(padding: const EdgeInsets.only(bottom: 18), child: _HistoryCard(item: e))),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _submit() async {
    final user = CurrentUser.user;
    if (user == null || _imagePath == null) return;
    await PortfolioService.submit(
      studentPhone: user.phone,
      studentName: user.name,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      imagePath: _imagePath!,
      courseId: _courseId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نمونه‌کار برای بررسی مدرس ارسال شد.')));
    setState(() {
      _imagePath = null;
      _courseId = null;
      _titleCtrl.clear();
      _descCtrl.clear();
    });
  }
}

class _AcademySummaryCard extends StatelessWidget {
  final double? average;
  const _AcademySummaryCard({required this.average});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surface.withValues(alpha: .8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: .2)),
      ),
      child: Stack(
        children: [
          Positioned(top: -30, right: -30, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppTheme.gold.withValues(alpha: .14), Colors.transparent])))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('آکادمی من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold.withValues(alpha: .1), border: Border.all(color: AppTheme.gold.withValues(alpha: .25))),
                    child: const Icon(Icons.school_rounded, color: AppTheme.gold, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('میانگین نمرات دوره‌ها', style: TextStyle(color: AppTheme.muted, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .5)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(average == null ? '—' : average!.toStringAsFixed(1), style: const TextStyle(color: AppTheme.gold, fontSize: 34, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 6),
                  const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('از ۲۰', style: TextStyle(color: AppTheme.muted, fontSize: 13))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyCourseRow extends StatelessWidget {
  final CourseCatalogItem course;
  const _MyCourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppTheme.surface.withValues(alpha: .8), border: Border.all(color: AppTheme.gold.withValues(alpha: .18))),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 68, height: 68, child: CourseImage(source: course.imageAsset))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 3),
                Text(course.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold)),
                  const SizedBox(width: 6),
                  const Text('ثبت‌نام‌شده', style: TextStyle(color: AppTheme.gold, fontSize: 10.5)),
                ]),
              ],
            ),
          ),
          Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.gold.withValues(alpha: .1), border: Border.all(color: AppTheme.gold.withValues(alpha: .3))), child: const Icon(Icons.play_arrow_rounded, color: AppTheme.gold)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PortfolioModel item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final reviewed = item.teacherScore != null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gold.withValues(alpha: reviewed ? .2 : .1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: reviewed ? 190 : 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CourseImage(source: item.imagePath),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC0D1420)]))),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .6), borderRadius: BorderRadius.circular(99), border: Border.all(color: AppTheme.gold.withValues(alpha: .2))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_statusIcon(item.status), size: 14, color: _statusColor(item.status)),
                      const SizedBox(width: 5),
                      Text(PortfolioService.statusLabel(item.status), style: TextStyle(color: _statusColor(item.status), fontSize: 10.5, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(18, reviewed ? 0 : 16, 18, 18),
            color: AppTheme.surface.withValues(alpha: .92),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          if (item.description.isNotEmpty) Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 11.5)),
                        ],
                      ),
                    ),
                    if (item.status == PortfolioStatus.approved)
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.gold.withValues(alpha: .35))),
                          child: Column(children: [
                            const Text('نمره نهایی', style: TextStyle(color: AppTheme.gold, fontSize: 8.5, fontWeight: FontWeight.w800)),
                            Text(item.finalScore?.toStringAsFixed(1) ?? '-', style: const TextStyle(color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.w900)),
                          ]),
                        ),
                      ),
                  ],
                ),
                if (reviewed) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .3), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.gold.withValues(alpha: .1))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: const [Icon(Icons.co_present_rounded, size: 18, color: AppTheme.muted), SizedBox(width: 6), Text('نمره استاد', style: TextStyle(fontSize: 12.5))]),
                            Text(item.teacherScore!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        if ((item.teacherFeedback ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(border: Border(right: BorderSide(color: AppTheme.gold.withValues(alpha: .4), width: 2))),
                            child: Text('«${item.teacherFeedback}»', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, height: 1.5)),
                          ),
                        ],
                        if (item.status == PortfolioStatus.approved) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.gold.withValues(alpha: .1)))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: const [Icon(Icons.stars_rounded, size: 18, color: AppTheme.gold), SizedBox(width: 6), Text('تصمیم مدیر', style: TextStyle(fontSize: 12.5, color: AppTheme.gold))]),
                                Text(item.managerAcceptedTeacherScore ? 'تأیید نمره استاد' : 'نمره جایگزین: ${item.managerScore?.toStringAsFixed(1)}', style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 11.5)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) => switch (status) {
        PortfolioStatus.approved => Icons.verified_rounded,
        PortfolioStatus.pendingManager => Icons.hourglass_top_rounded,
        PortfolioStatus.rejected => Icons.cancel_rounded,
        _ => Icons.hourglass_empty_rounded,
      };

  Color _statusColor(String status) => switch (status) {
        PortfolioStatus.approved => AppTheme.gold,
        PortfolioStatus.rejected => AppTheme.danger,
        _ => AppTheme.muted,
      };
}
