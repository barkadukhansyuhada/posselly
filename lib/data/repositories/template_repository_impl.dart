import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/template.dart';
import '../../domain/repositories/template_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/config/supabase_config.dart';
import '../models/template_model.dart';
import '../datasources/local/sqlite_datasource.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final SqliteDatasource localDatasource;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  TemplateRepositoryImpl(
    this.localDatasource,
    SqliteDatasource remoteDatasource,
  );

  @override
  Future<Either<Failure, List<Template>>> getTemplates() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult != ConnectivityResult.none) {
        // Try to get from remote
        final user = _supabaseClient.auth.currentUser;
        if (user != null) {
          final response = await _supabaseClient
              .from(SupabaseConfig.templatesTable)
              .select()
              .eq('user_id', user.id)
              .order('usage_count', ascending: false);

          final templates = (response as List)
              .map((json) => TemplateModel.fromJson(json))
              .toList();

          // Cache templates locally
          await localDatasource.cacheTemplates(templates);
          
          return Right(templates);
        }
      }
      
      // Fallback to cached templates
      final cachedTemplates = await localDatasource.getTemplates();
      return Right(cachedTemplates);
    } on ServerException catch (e) {
      // Try cached data on error
      try {
        final cachedTemplates = await localDatasource.getTemplates();
        return Right(cachedTemplates);
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Template>>> getTemplatesByCategory(
      String category) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult != ConnectivityResult.none) {
        final user = _supabaseClient.auth.currentUser;
        if (user != null) {
          final response = await _supabaseClient
              .from(SupabaseConfig.templatesTable)
              .select()
              .eq('user_id', user.id)
              .eq('category', category)
              .order('usage_count', ascending: false);

          final templates = (response as List)
              .map((json) => TemplateModel.fromJson(json))
              .toList();
          
          return Right(templates);
        }
      }
      
      final cachedTemplates = await localDatasource.getTemplatesByCategory(category);
      return Right(cachedTemplates);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Template>> createTemplate({
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User tidak terautentikasi'));
      }

      final templateData = {
        'user_id': user.id,
        'title': title,
        'content': content,
        'category': category,
        'usage_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseClient
          .from(SupabaseConfig.templatesTable)
          .insert(templateData)
          .select()
          .single();

      final template = TemplateModel.fromJson(response);
      
      // Cache locally
      await localDatasource.insertTemplate(template);
      
      return Right(template);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, Template>> updateTemplate({
    required String id,
    String? title,
    String? content,
    String? category,
  }) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (category != null) updateData['category'] = category;

      final response = await _supabaseClient
          .from(SupabaseConfig.templatesTable)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final template = TemplateModel.fromJson(response);
      
      // Update locally
      await localDatasource.updateTemplate(template);
      
      return Right(template);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return const Left(NetworkFailure('Tidak ada koneksi internet'));
      }

      await _supabaseClient
          .from(SupabaseConfig.templatesTable)
          .delete()
          .eq('id', id);

      // Delete locally
      await localDatasource.deleteTemplate(id);
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUsage(String id) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult != ConnectivityResult.none) {
        await _supabaseClient.rpc('increment_template_usage', params: {
          'template_id': id,
        });
      }
      
      // Update local cache
      await localDatasource.incrementTemplateUsage(id);
      
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Terjadi kesalahan: $e'));
    }
  }
}