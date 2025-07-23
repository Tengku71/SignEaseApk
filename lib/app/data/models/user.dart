import 'package:get/get.dart';

class UserModel {
  String name;
  String profileImage;
  RxInt level;
  List<String> history;
  String email;
  int points;
  String authType; // 👈 Tambahkan

  UserModel({
    required this.name,
    required this.profileImage,
    required int level,
    required this.history,
    required this.email,
    required this.points,
    this.authType = 'manual', // default manual
  }) : level = level.obs;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      profileImage: map['profileImage'] ?? '',
      level: int.tryParse(map['level'].toString()) ?? 0,
      history: List<String>.from(map['history'] ?? []),
      email: map['email'] ?? '',
      points: map['points'] ?? 0,
      authType: map['auth_type'] ?? 'manual', // 👈 Ambil dari DB
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profileImage': profileImage,
      'level': level.value,
      'history': history,
      'email': email,
      'points': points,
      'auth_type': authType,
    };
  }
}
