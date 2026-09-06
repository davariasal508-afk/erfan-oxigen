class UserModel {
  String name;
  String phone;
  String password;
  String role;
  bool active;
  Map<String, bool> permissions;
  String? specialty;
  String? course;
  String? fatherPhone;
  String? nationalId;
  String? photoPath;

  UserModel({
    required this.name,
    required this.phone,
    required this.password,
    required this.role,
    required this.active,
    required this.permissions,
    this.specialty,
    this.course,
    this.fatherPhone,
    this.nationalId,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'password': password,
        'role': role,
        'active': active,
        'permissions': permissions,
        'specialty': specialty,
        'course': course,
        'fatherPhone': fatherPhone,
        'nationalId': nationalId,
        'photoPath': photoPath,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        password: json['password'] ?? '',
        role: json['role'] ?? '',
        active: json['active'] ?? true,
        permissions: Map<String, bool>.from(json['permissions'] ?? {}),
        specialty: json['specialty'],
        course: json['course'],
        fatherPhone: json['fatherPhone'],
        nationalId: json['nationalId'],
        photoPath: json['photoPath'],
      );
}
