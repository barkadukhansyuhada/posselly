import 'package:dartz/dartz.dart';

import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';

class RegisterUsecase {
  final AuthRepository repository;
  
  RegisterUsecase(this.repository);
  
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      businessName: businessName,
      phone: phone,
    );
  }
}