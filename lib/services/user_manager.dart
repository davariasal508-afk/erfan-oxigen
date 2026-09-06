import '../models/user_model.dart';
import 'storage_service.dart';
import 'users_data.dart';

class UserManager {
  static final List<UserModel> users = [];

  static Future<void> initialize() async {
    final loadedUsers = await StorageService.loadUsers();

    if (loadedUsers.isEmpty) {
      users
        ..clear()
        ..addAll(UserData.users);

      await StorageService.saveUsers(users);
      return;
    }

    users
      ..clear()
      ..addAll(loadedUsers);
  }

  static Future<void> loadUsers() async {
    final loadedUsers = await StorageService.loadUsers();

    users
      ..clear()
      ..addAll(loadedUsers);

    // اگر ذخیره‌سازی خالی یا خراب بود،
    // کاربران اولیه را دوباره وارد می‌کنیم.
    if (users.isEmpty) {
      users
        ..clear()
        ..addAll(UserData.users);

      await StorageService.saveUsers(users);
    }
  }

  static Future<void> addUser(UserModel user) async {
    users.add(user);

    await StorageService.saveUsers(users);
  }

  static Future<void> updateUser(UserModel oldUser, UserModel newUser) async {
    final index = users.indexOf(oldUser);

    if (index != -1) {
      users[index] = newUser;

      await StorageService.saveUsers(users);
    }
  }

  static Future<void> removeUser(UserModel user) async {
    users.remove(user);

    await StorageService.saveUsers(users);
  }

  static List<UserModel> getUsersByRole(String role) {
    return users.where((user) => user.role == role).toList();
  }

  static void clearUsers() {
    users.clear();
  }

  static Future<void> clearStoredUsers() async {
    users.clear();

    await StorageService.clearUsers();
  }

  static Future<void> resetToDefaultUsers() async {
    users
      ..clear()
      ..addAll(UserData.users);

    await StorageService.saveUsers(users);
  }
}
