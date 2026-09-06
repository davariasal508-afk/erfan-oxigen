import '../models/user_model.dart';
import 'user_manager.dart';

class LoginService {
  static UserModel? login(String phone, String password) {
    final matchingUsers = UserManager.users.where(
      (user) =>
          user.phone == phone &&
          user.password == password &&
          user.active == true,
    );

    if (matchingUsers.isEmpty) {
      return null;
    }

    return matchingUsers.first;
  }
}
