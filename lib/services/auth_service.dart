import '../models/user_model.dart';
import 'current_user.dart';
import 'session_service.dart';
import 'user_manager.dart';

class AuthService {
  static Future<UserModel?> login(String phone, String password) async {
    await UserManager.initialize();

    String normalize(String value) {
      var v = value.trim().replaceAll(' ', '').replaceAll('-', '');
      if (v.startsWith('0098')) v = '+98${v.substring(4)}';
      if (v.startsWith('98') && !v.startsWith('+')) v = '+$v';
      if (v.startsWith('0')) v = '+98${v.substring(1)}';
      return v;
    }

    final cleanPhone = normalize(phone);
    final cleanPassword = password.trim();

    UserModel? user;

    try {
      user = UserManager.users.firstWhere(
        (item) =>
            normalize(item.phone) == cleanPhone &&
            item.password.trim() == cleanPassword &&
            item.active,
      );
    } catch (e) {
      user = null;
    }

    if (user == null) {
      return null;
    }

    CurrentUser.user = user;

    await SessionService.createSession(user);

    return user;
  }

  static Future<void> logout() async {
    await SessionService.logout();
  }

  static Future<bool> isLoggedIn() async {
    return await SessionService.hasValidSession();
  }
}
