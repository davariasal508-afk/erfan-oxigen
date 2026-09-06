import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendApi {
  static const enabledKey = 'backend_enabled';
  static const baseUrlKey = 'backend_base_url';
  static String baseUrl = 'http://127.0.0.1:8787';
  static bool enabled = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(baseUrlKey) ?? baseUrl;
    enabled = prefs.getBool(enabledKey) ?? false;
  }

  static Future<void> setConfig({required bool isEnabled, required String url}) async {
    final prefs = await SharedPreferences.getInstance();
    enabled = isEnabled;
    baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setBool(enabledKey, enabled);
    await prefs.setString(baseUrlKey, baseUrl);
  }

  static Future<bool> health() async {
    if (!enabled) return false;
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> get(String path) async {
    if (!enabled) return null;
    try {
      final response = await http.get(Uri.parse('$baseUrl$path')).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body) async {
    if (!enabled) return null;
    try {
      final response = await http.post(Uri.parse('$baseUrl$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }
}
