import 'package:dartz/dartz.dart';

import '../entities/template.dart';
import '../../core/errors/failures.dart';

abstract class TemplateRepository {
  Future<Either<Failure, List<Template>>> getTemplates();
  Future<Either<Failure, List<Template>>> getTemplatesByCategory(String category);
  Future<Either<Failure, Template>> createTemplate({
    required String title,
    required String content,
    required String category,
  });
  Future<Either<Failure, Template>> updateTemplate({
    required String id,
    String? title,
    String? content,
    String? category,
  });
  Future<Either<Failure, void>> deleteTemplate(String id);
  Future<Either<Failure, void>> incrementUsage(String id);
}