import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import 'current_user.dart';
import 'user_manager.dart';

class SessionService {
  static const String phoneKey = 'oxygen_session_phone';
  static const String loginTimeKey = 'oxygen_session_login_time';

  static DateTime? loginTime;

  static String _normalizePhone(String value) {
    var v = value.trim().replaceAll(' ', '').replaceAll('-', '');
    if (v.startsWith('0098')) v = '+98${v.substring(4)}';
    if (v.startsWith('98') && !v.startsWith('+')) v = '+$v';
    if (v.startsWith('0')) v = '+98${v.substring(1)}';
    return v;
  }

  static Future<void> createSession(UserModel user) async {
    CurrentUser.user = user;

    loginTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(phoneKey, user.phone);
    await prefs.setString(loginTimeKey, loginTime!.toIso8601String());
  }

  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    final phone = prefs.getString(phoneKey);
    final savedLoginTime = prefs.getString(loginTimeKey);

    if (phone == null) {
      return false;
    }

    if (savedLoginTime != null) {
      try {
        loginTime = DateTime.parse(savedLoginTime);
      } catch (_) {
        loginTime = null;
      }
    }

    UserModel? user;

    try {
      user = UserManager.users.firstWhere(
        (item) => _normalizePhone(item.phone) == _normalizePhone(phone) && item.active == true,
      );
    } catch (e) {
      user = null;
    }

    if (user == null) {
      await logout();
      return false;
    }

    CurrentUser.user = user;

    return true;
  }

  static Future<bool> hasValidSession() async {
    return restoreSession();
  }

  static Future<void> logout() async {
    CurrentUser.clear();

    loginTime = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(phoneKey);
    await prefs.remove(loginTimeKey);
  }
}
