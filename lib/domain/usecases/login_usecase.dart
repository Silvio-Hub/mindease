import 'package:mindease/domain/entities/user.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(String email, String password) async {
    final user = await repository.signInWithEmail(email, password);
    if (user == null) {
      throw Exception('Login failed');
    }
    return user;
  }
}
