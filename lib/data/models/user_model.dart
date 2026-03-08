import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'] as String,
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'fullName': fullName};
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(id: user.id, email: user.email, fullName: user.fullName);
  }
}
