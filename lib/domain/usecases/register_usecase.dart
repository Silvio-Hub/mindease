import 'package:mindease/domain/entities/user.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(String fullName, String email, String password) async {
    final user = await repository.signUpWithEmail(email, password, fullName);
    if (user == null) {
      throw Exception('Registration failed');
    }
    return user;
  }
}
