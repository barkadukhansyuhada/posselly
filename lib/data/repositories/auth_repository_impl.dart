import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../datasources/local/preferences_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDatasource remoteDatasource;
  final PreferencesDatasource localDatasource;
  
  AuthRepositoryImpl(
    this.remoteDatasource,
    this.localDatasource,
  );

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final user = await remoteDatasource.login(
        email: email,
        password: password,
      );
      
      await localDatasource.cacheUser(user);
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String businessName,
    String? phone,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final user = await remoteDatasource.register(
        email: email,
        password: password,
        businessName: businessName,
        phone: phone,
      );
      
      await localDatasource.cacheUser(user);
      
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDatasource.logout();
      await localDatasource.clearCache();
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult != ConnectivityResult.none) {
        // Try to get from remote first
        final remoteUser = await remoteDatasource.getCurrentUser();
        if (remoteUser != null) {
          await localDatasource.cacheUser(remoteUser);
          return Right(remoteUser);
        }
      }
      
      // Fallback to cached user
      final cachedUser = await localDatasource.getCachedUser();
      return Right(cachedUser);
    } on ServerException catch (e) {
      // If remote fails, try to get cached user
      try {
        final cachedUser = await localDatasource.getCachedUser();
        return Right(cachedUser);
      } on CacheException {
        return Left(ServerFailure(message: e.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? businessName,
    String? phone,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      await remoteDatasource.updateProfile(
        businessName: businessName,
        phone: phone,
      );
      
      // Update cached user
      final cachedUser = await localDatasource.getCachedUser();
      if (cachedUser != null) {
        final updatedUser = cachedUser.copyWith(
          businessName: businessName ?? cachedUser.businessName,
          phone: phone ?? cachedUser.phone,
        );
        await localDatasource.cacheUser(UserModel.fromEntity(updatedUser));
      }
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDatasource.authStateChanges;
  }
}