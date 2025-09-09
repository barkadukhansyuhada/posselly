import 'package:dartz/dartz.dart';

import '../../repositories/invoice_repository.dart';
import '../../../core/errors/failures.dart';

class GeneratePdfUsecase {
  final InvoiceRepository repository;
  
  GeneratePdfUsecase(this.repository);
  
  Future<Either<Failure, String>> call(String invoiceId) async {
    return await repository.generatePdf(invoiceId);
  }
}