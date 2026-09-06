import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'course_catalog_service.dart';

class CourseEnrollmentService {
  static const String _key = 'erfan_oxygen_course_enrollments_v1';
  static final Map<String, List<String>> _enrollments = {};

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _enrollments
        ..clear()
        ..addAll(decoded.map(
          (key, value) => MapEntry(
            key,
            List<String>.from(value as List<dynamic>),
          ),
        ));
    } catch (_) {
      _enrollments.clear();
    }
  }

  static List<String> enrolledPhones(String courseId) =>
      List<String>.from(_enrollments[courseId] ?? const []);

  static int count(String courseId) => _enrollments[courseId]?.length ?? 0;

  static bool isEnrolled(String courseId, String phone) =>
      _enrollments[courseId]?.contains(phone) ?? false;

  static Future<bool> enroll(String courseId, String phone) async {
    final course = CourseCatalogService.byId(courseId);
    if (course == null) return false;
    if (isEnrolled(courseId, phone)) return true;
    if (count(courseId) >= course.capacity) return false;

    (_enrollments[courseId] ??= []).add(phone);
    await _save();
    return true;
  }

  static Future<void> cancel(String courseId, String phone) async {
    _enrollments[courseId]?.remove(phone);
    await _save();
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_enrollments));
  }
}
