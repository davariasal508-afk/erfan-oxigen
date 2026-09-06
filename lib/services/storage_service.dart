import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/exam_model.dart';

class StorageService {
  static const String usersKey = 'oxygen_users';
  static const String examsKey = 'oxygen_exams';
  static const String adminDisplayNameKey = 'oxygen_admin_display_name';
  static const String adsKey = 'oxygen_ads';
  static const String chatMessagesKey = 'oxygen_chat_messages';
  static const String chatThreadsKey = 'oxygen_chat_threads';

  // =========================
  // USERS
  // =========================

  static Future<void> saveUsers(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();

    final data = users.map((user) => user.toJson()).toList();

    await prefs.setString(usersKey, jsonEncode(data));
  }

  static Future<List<UserModel>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(usersKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);

      return decoded
          .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(usersKey);
  }

  // =========================
  // EXAMS
  // =========================

  static Future<void> saveExams(List<ExamModel> exams) async {
    final prefs = await SharedPreferences.getInstance();

    final data = exams.map((exam) => exam.toJson()).toList();

    await prefs.setString(examsKey, jsonEncode(data));
  }

  static Future<List<ExamModel>> loadExams() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(examsKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);

      return decoded
          .map((item) => ExamModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> loadAdminDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(adminDisplayNameKey) ?? 'عرفان';
  }

  static Future<void> saveAdminDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(adminDisplayNameKey, name.trim().isEmpty ? 'عرفان' : name.trim());
  }

  static Future<void> saveAds(List<Map<String, dynamic>> ads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(adsKey, jsonEncode(ads));
  }

  static Future<List<Map<String, dynamic>>> loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(adsKey);
    if (data == null || data.isEmpty) return [];
    try {
      return (jsonDecode(data) as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveChat(List<Map<String, dynamic>> messages, List<Map<String, dynamic>> threads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(chatMessagesKey, jsonEncode(messages));
    await prefs.setString(chatThreadsKey, jsonEncode(threads));
  }

  static Future<(List<Map<String, dynamic>>, List<Map<String, dynamic>>)> loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final m = jsonDecode(prefs.getString(chatMessagesKey) ?? '[]') as List;
      final t = jsonDecode(prefs.getString(chatThreadsKey) ?? '[]') as List;
      return (m.map((e) => Map<String, dynamic>.from(e)).toList(), t.map((e) => Map<String, dynamic>.from(e)).toList());
    } catch (_) {
      return (<Map<String, dynamic>>[], <Map<String, dynamic>>[]);
    }
  }

  static Future<void> clearExams() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(examsKey);
  }
  static Future<void> saveGenericList(String key, List<Map<String, dynamic>> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(values));
  }

  static Future<List<Map<String, dynamic>>> loadGenericList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null || data.isEmpty) return [];
    try {
      final decoded = jsonDecode(data) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

}
