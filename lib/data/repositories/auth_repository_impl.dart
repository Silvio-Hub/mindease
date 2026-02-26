import 'package:mindease/data/datasources/auth_local_datasource.dart';
import 'package:mindease/domain/entities/user.dart';
import 'package:mindease/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> login(String email, String password) async {
    // Simulação de chamada de API
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.length >= 6) {
      // Mock de sucesso para qualquer email válido e senha >= 6 chars
      // Em um cenário real, validaria contra API ou banco local
      final user = User(id: '1', email: email, name: email.split('@').first);
      await _dataSource.saveUser(user);
      return user;
    } else {
      throw Exception('Credenciais inválidas');
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      final user = User(id: DateTime.now().toString(), email: email, name: name);
      await _dataSource.saveUser(user);
      return user;
    } else {
      throw Exception('Dados inválidos para cadastro');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _dataSource.clearUser();
  }

  @override
  Future<User?> getCurrentUser() async {
    return _dataSource.getUser();
  }
}
