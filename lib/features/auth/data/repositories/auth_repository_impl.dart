import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);
  final AuthRemoteDataSource _dataSource;

  @override
  AuthUser? get currentUser => _dataSource.currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _dataSource.authStateChanges;

  @override
  Future<Result<AuthUser>> signIn({
    required String email,
    required String password,
  }) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<Result<AuthUser?>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _dataSource.signUp(fullName: fullName, email: email, password: password);

  @override
  Future<Result<void>> signInWithGoogle() => _dataSource.signInWithGoogle();

  @override
  Future<Result<void>> signOut() => _dataSource.signOut();

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      _dataSource.sendPasswordResetEmail(email);

  @override
  Future<Result<void>> updatePassword(String newPassword) =>
      _dataSource.updatePassword(newPassword);

  @override
  Future<Result<void>> deleteAccount() => _dataSource.deleteAccount();
}
