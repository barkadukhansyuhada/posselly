import 'package:dartz/dartz.dart';

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

class LoginUsecase {
  final AuthRepository repository;
  
  LoginUsecase(this.repository);
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}