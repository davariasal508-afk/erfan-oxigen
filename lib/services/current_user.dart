import '../models/user_model.dart';

class CurrentUser {
  static UserModel? user;

  static void setUser(UserModel loggedInUser) {
    user = loggedInUser;
  }

  static void clear() {
    user = null;
  }

  static bool get isLoggedIn {
    return user != null;
  }

  static String get name {
    return user?.name ?? "";
  }

  static String get phone {
    return user?.phone ?? "";
  }

  static String get role {
    return user?.role ?? "";
  }

  static String get specialty {
    return user?.specialty ?? "";
  }

  static String get course {
    return user?.course ?? "";
  }

}
