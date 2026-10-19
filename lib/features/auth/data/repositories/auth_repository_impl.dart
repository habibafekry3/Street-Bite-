import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;
  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _dataSource.login(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return await _dataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } on FirebaseAuthException {
      rethrow;
    }
  }
}
