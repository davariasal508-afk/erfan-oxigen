import '../models/user_model.dart';

class UserData {
  static final List<UserModel> users = [
    UserModel(
      name: "مدیر اصلی",
      phone: "09134255139",
      password: "1234",
      role: "admin",
      specialty: "",
      course: "",
      active: true,
      permissions: {
        "manageUsers": true,
        "viewStudents": true,
        "sendMessage": true,
        "viewReports": true,
        "editContent": true,
      },
    ),

    UserModel(
      name: "سارا احمدی",
      phone: "09372623001",
      password: "1234",
      role: "teacher",
      specialty: "رنگ و مش مو",
      course: "",
      active: true,
      permissions: {
        "manageUsers": false,
        "viewStudents": true,
        "sendMessage": true,
        "viewReports": false,
        "editContent": true,
      },
    ),

    UserModel(
      name: "علی رضایی",
      phone: "09330000000",
      password: "1234",
      role: "student",
      specialty: "",
      course: "آرایشگری حرفه‌ای",
      active: true,
      permissions: {
        "manageUsers": false,
        "viewStudents": false,
        "sendMessage": true,
        "viewReports": false,
        "editContent": false,
      },
    ),
  ];

  static UserModel? login(String phone, String password) {
    try {
      return users.firstWhere(
        (user) =>
            user.phone == phone &&
            user.password == password &&
            user.active == true,
      );
    } catch (e) {
      return null;
    }
  }
}
