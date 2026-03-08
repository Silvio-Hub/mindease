import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signInWithEmail(String email, String password);
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String fullName,
  );
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      debugPrint('Tentando login com email: $email');
      final credential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Tempo limite de conexão excedido (15s)'),
          );

      if (credential.user != null) {
        debugPrint('Login Firebase Auth sucesso.');
        return _mapFirebaseUserToUserModel(credential.user!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro no login: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel?> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      debugPrint('Tentando cadastro com email: $email');
      final credential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Tempo limite de conexão excedido (15s)'),
          );

      if (credential.user != null) {
        debugPrint('Cadastro Firebase Auth sucesso. Atualizando perfil...');
        // Atualiza o nome do usuário no Firebase Auth
        await credential.user!.updateDisplayName(fullName);
        await credential.user!
            .reload(); // Recarrega para garantir que o nome foi salvo

        final updatedUser = firebaseAuth.currentUser;

        return _mapFirebaseUserToUserModel(updatedUser!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro no cadastro: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return _mapFirebaseUserToUserModel(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return _mapFirebaseUserToUserModel(user);
    });
  }

  UserModel _mapFirebaseUserToUserModel(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? '',
    );
  }
}
