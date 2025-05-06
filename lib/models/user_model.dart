class UserModel {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String gender;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.gender,
    required this.role,
  });

  factory UserModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'],
      phone: json['phone'],
      password: json['password'],
      gender: json['gender'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'password': password,
      'gender': gender,
      'role': role,
    };
  }
}