import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindease/domain/entities/user.dart';

class AuthLocalDataSource {
  static const String userKey = 'user';
  final Box<Map> box;

  AuthLocalDataSource(this.box);

  Future<User?> getUser() async {
    final data = box.get(userKey);
    if (data != null) {
      return User(
        id: data['id'] as String,
        email: data['email'] as String,
        fullName: (data['fullName'] ?? data['name'] ?? '') as String,
      );
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    await box.put(userKey, {
      'id': user.id,
      'email': user.email,
      'fullName': user.fullName,
    });
  }

  Future<void> clearUser() async {
    await box.delete(userKey);
  }
}
