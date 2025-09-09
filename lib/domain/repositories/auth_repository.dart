import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, User?>> getCurrentUser();
  
  Future<Either<Failure, void>> updateProfile({
    String? businessName,
    String? phone,
  });
  
  Stream<User?> get authStateChanges;
}