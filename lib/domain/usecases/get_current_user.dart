import 'package:mindease/domain/entities/user.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<User?> call() {
    return repository.getCurrentUser();
  }
}
